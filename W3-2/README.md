# 合约升级

个人在学习中的收获，请见 [personal-gains.md](./personal-gains.md) 文件。

## 项目目标

- 部署⼀个可升级的 ERC20 Token
  - 第⼀版本
  - 第⼆版本，加⼊⽅法：function transferWithCallback(address recipient, uint256 amount) external returns (bool)

目标分析：
1. 在第一版的合约中，继承可升级的 ERC20-upgradeable.sol，实现基础的 ERC20 功能即可。
2. 在第二版的合约中，额外添加可以直接向 Vault 合约转账的函数。
3. 通过 OpenZeppelin Upgrades 插件实现合约的升级和管理。

## 代码介绍

### MyERC20V1.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MyERC20V1 is ERC20Upgradeable {
    function initialize() initializer external {
        __ERC20_init("MyERC20", "MER");
        _mint(msg.sender, 1000e18);
    }
}
```

1. 导入了 @openzeppelin/contracts-upgradeable 代码中的 ERC20Upgradeable.sol。
2. 继承可升级 ERC20Upgradeable 合约。
3. 实现可升级合约的初始化，记得要使用 initialize() 函数和 initializer 修饰器。
4. 调用 ERC20Upgradeable 的 __ERC20_init 初始化函数。
5. 调用 ERC20 的 _mint 函数。

注意：

1. 升级合约与普通合约在命名上的区别是增加了 Upgradeable 后缀。
2. 注意可升级合约的写法： function initialize() initializer external {};
3. ERC20Upgradeable 的初始化函数调用 __ERC20_init("{name}", "{symbol}");


### IRecipient.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRecipient {
    function tokensReceived(address sender, uint256 amount) external returns(bool);
}
```

ERC20 与 Vault 合约交互的接口，规定了 Vault 合约对余额的处理方式。

### MyERC20V2.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./IRecipient.sol";

contract MyERC20V2 is ERC20Upgradeable {
    
    using AddressUpgradeable for address;

    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        require(transfer(recipient, amount), "Transfer failed");

        if (recipient.isContract()) {
            require(IRecipient(recipient).tokensReceived(msg.sender, amount), "Unprocessed transfer");
        }

        return true;
    }
}
```

这里新增了 transferWithCallback() 函数，它的逻辑主要是两步：

1. 将 ERC20 代币 transfer 至 vault 合约。
2. 调用 vault 合约的 tokenReceived() 函数。

这个步骤主要是防止代币被转账至不打算处理转账函数的合约，从而避免代币锁死在合约当中。

同时，MyERC20V2 并没有新增初始化函数，也就意味着它无需重置或新增某些变量。

### Vault.sol

```solidity
function tokensReceived(address sender, uint256 amount) external override returns(bool) {
    require(msg.sender == address(_token), "Invalid address");
    _balances[sender] += amount;
    return true;
}
```

这一部分的核心是实现 tokenReceived() 函数，本质上就是做 balances[] 的处理。

### deploy.js

```js
const { ethers, upgrades } = require("hardhat");

async function deployMyERC20V1() {
    const MyERC20V1 = await ethers.getContractFactory("MyERC20V1");
    console.log("Deploying MyERC20V1...");
    const myERC20V1 = await upgrades.deployProxy(MyERC20V1);
    await myERC20V1.deployed();
    console.log("MyERC20V1 deployed!");
    return myERC20V1;
}

function wait(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
  

async function verifyContract(contract, contractName, constructorArguments = []) {
    console.log("Waiting for 30 seconds before verifying...");
    await wait(30000);
    
    console.log(`Verifying ${contractName} on Etherscan...`);
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: constructorArguments,
    });

    console.log(`${contractName} verified on Etherscan`);
}

async function upgradeToMyERC20V2(proxyAddress) {
    const MyERC20V2 = await ethers.getContractFactory("MyERC20V2");
    console.log("Upgrading to MyERC20V2...");
    await upgrades.upgradeProxy(proxyAddress, MyERC20V2);
    console.log("Upgraded to MyERC20V2!");
    return await ethers.getContractAt("MyERC20V2", proxyAddress);
}

async function deployVault(proxyAddress) {
    const Vault = await ethers.getContractFactory("Vault");
    console.log("Deploying Vault...");
    const vault = await Vault.deploy(proxyAddress);
    await vault.deployed();
    console.log("Vault deployed!");
    return vault;
}

async function main() {
    // Deploy MyERC20V1
    const myERC20V1 = await deployMyERC20V1();
    const admin = await upgrades.admin.getInstance();
    const implAddress = await admin.getProxyImplementation(myERC20V1.address);
    await verifyContract(myERC20V1, "myERC20V1");

    // Upgrade to MyERC20V2
    const myERC20V2 = await upgradeToMyERC20V2(myERC20V1.address);
    const newImplAddress = await admin.getProxyImplementation(myERC20V1.address);
    await verifyContract(myERC20V2, "myERC20V2");

    // Deploy Vault contract
    const vault = await deployVault(myERC20V2.address);
    await verifyContract(vault, "vault", [myERC20V2.address]);

    console.log("MyERC20V1 proxy deployed to: ", myERC20V1.address);
    console.log("MyERC20V1 implementation deployed to: ", implAddress);
    console.log("MyERC20V2 implementation deployed to: ", newImplAddress);
    console.log("Vault deployed to: ", vault.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

这部分主要展示了三个方面：

1. 可升级合约的部署： await upgrades.deploy({contract name});
2. 合约的升级：await upgrades.upgradeProxy({contract name});
3. 多合约部署、升级、验证的一体化：定义每个合约的部署/升级函数和一个验证函数，再通过 main() 函数依次执行这些函数并传递参数。

## 运行结果

以下是所有合约部署在 Sepolia 测试链上的结果：

1. Admin 管理员合约： 0xc25806DacD2Dd2d3DB3f5f0a07885862C0d754a4
2. Proxy 代理合约： 0x5a6d510966022Edd36f0442AeFc7F14cb5d0C68D
3. MyERC20V1 实现合约： 0x69F275bCC40D6C1ff46d335FF4C09D2239d5419f
4. MyERC20V2 实现合约:  0x69F275bCC40D6C1ff46d335FF4C09D2239d5419f
5. Vault 合约： 0x18Ff01B69B5265b694035cF4838d92Fe7f9A3D6E

所有代码均已开源。