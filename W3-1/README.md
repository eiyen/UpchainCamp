# 代币与市场

这个项目是用来发行 ERC20 和 ERC721 代币，并通过 NFTMarket 市场实现两者的交易。

## 项目目标

1. ERC20 篇
   1. 发行自己的 ERC20 代币，并实现 premint 功能。
   2. 发布 Vault 合约，实现：⓵ 关联代币；⓶ 存储资金；⓷ 取出资金；⓸ 查询余额；
   3. 拓展：实现 ERC20 无需授权、直接转账的功能。
2. ERC721 篇
   1. 发布 ERC721 合约，实现 safeMint 功能。
   2. 通过 URI 铸造自己的 NFT.
   3. 查看 NFT 的铸造结果。
3. NFTMarket 篇
   1. 实现 NFT 上架功能。
   2. 实现 NFT 购买功能。
   3. 拓展：能够处理 safeTransfer 请求。

## 实现过程

### 一、ERC20 篇

这一部分需要实现 MyERC20 代币的发行，Vault 合约与 MyERC20 代币的交互，以及防锁死功能的实现。

#### 1. MyERC20 合约

在 [`MyERC20.sol`](./contracts/ERC20/MyERC20.sol) 中实现以下代码：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9
```

这两步是用来指定开源许可证的类型以及 Solidity 编译器的版本，后面将忽略这一部分的解释。

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

这一步是导入我们所需的合约，我们将直接继承 OpenZeppelin 已经实现好的安全合约。

```solidity
contract MyERC20 is ERC20 {

}
```

这一步用来创建 MyERC20 合约，并使其继承自 OpenZeppelin 的 ERC20 合约。

```solidity
   constructor() ERC20("MyERC20", "MER") {
      _mint(msg.sender, 1000 * 10 ** decimals());
   }
```

这一步便涉及到了多个 ERC20 部分的知识点：

1. 多合约初始化：
   - 在这里有两个需要初始化的合约，一个是本合约的初始化，另一个是父合约的初始化。
   - 初始化本合约时，依然使用 `constructor()` 函数。
   - 初始化父合约时，需要在 `constructor()` 后添加父合约的名称及其参数
     - ERC20 的初始化的语法是：`ERC20("<name>", "<symbol>")`，在这里是 `ERC20("MyERC20", "MER")`.
2. premint
   1. 概念：premint 的概念类似于初始铸造（Initial Mint），或者是私募（Private Sale）。
   2. premint 是指在初始化函数中，执行 `_mint()` 函数
      1. `_mint()` 函数的语法是 `_mint(<to>, <value>)`, 这里是 `_mint(msg.sender, 1000 * 10 ** decimals())`.
      2. `decimals()` 是 ERC20 中定义的函数，它代表代币的小数点位数，默认返回 18.

#### 2. Vault 合约

在 [Vault.sol](./contracts/ERC20/Vault.sol) 中实现四个基本功能：⓵ 关联代币；⓶ 存储资金；⓷ 取出资金。

##### 2.1 关联代币

```solidity
   IERC20 private _token;

   constructor(address tokenAddress) {
      _token = tokenAddress;
   }

   function token() external view returns(address) {
      return _token;
   }
```

在初始化合约时，我们需要将 MyERC20 合约地址传给 Vault 合约，从而让 Vault 合约能够通过 IERC20 接口和 MyERC20 合约地址访问代币。

注意，我们在声明 `_token` 变量时，采用了封装（Encapsulation）的概念，这样隐藏了它的潜在功能，使其在合约继承、合约升级等情况下不会被误修改。而通过 `token()` 函数，我们能做到只暴露了它可读的功能。具体可看 [ChatGPT的解释](https://sharegpt.com/c/GKvUcD8)。

##### 2.2 存储资金

```solidity
   mapping[address => uint256] private _balances;

   function deposit(uint256 amount) external {
      require(IERC20(_token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
      _balances[msg.sender] += amount;
   }

   function balanceOf() external view returns(uint256) {
      return _balances[msg.sender];
   }   
```

在以上代码中 `deposit(uint256 amount)` 函数实现了存储和记录功能，其中：
- `_balances[]` 映射用来存储用户和对应的存储资金。
- `IERC20(_token)` 用来调用 `MyERC20` 中的函数。
- `transferFrom()` 会返回 `bool` 值，因此将其写在 `require()` 错误处理中判断交易是否成功。

##### 2.3 取出资金

```solidity
   function withdraw(uint256 amount) external {
      require(amount > 0, "Invalid amount");
      require(amount <= _balances[msg.sender], "Insufficient fund");
      _balances[msg.sender] -= amount;
      require(IERC20(_token).transfer(msg.sender, amount), "Transfer failed");
   }
```

在 `withdraw()` 取出资金之前，需要判断 `amount` 的值是否在0~余额之间。

#### 3. IRecipient 接口

在实现了基本功能的情况下，我们可以额外实现「防锁死」的功能。我们可以借助 IERC777Recipient 的思路来实现这一接口。

##### 3.1 IRecipient 接口编写

在 [IRecipient.sol](./contracts/ERC20/IRecipient.sol) 中编写该接口：

```solidity
interface IRecipient {
   function tokenReceived(address from, uint256 amount) external returns(bool);
}
```

`tokenReceived()` 函数类似于 `onTokenTransfer()` 函数，都是用来处理直接向合约发起交易的转账，防止代币锁死。

##### 3.2 IRecipient 接口实现

在 [Vault.sol](./contracts/ERC20/Vault.sol) 中实现该接口：

```solidity
import "./IRecipient";

constrct Vault is IRecipient {
   function tokenReceived(address to, uint256 amount) external returns(bool) {
      require(msg.sender == _token, "Invalid address");
      _balances[to] += amount;
   }
}
```

注意，这里的 `msg.sender` 不同于 `from`, 因为 `msg.sender` 代表 `MyERC20` 合约地址，而 `from` 代表用户地址。

##### 3.3 IRecipient 接口调用

在 [MyERC20.sol](./contracts/ERC20/MyERC20.sol) 中导入并调用 IRecipient 接口：

```solidity
import "./IRecipient";

contract MyERC20 is ERC20 {
   function transferWithCallback(address recipient, uint256 amount) external {
      require(recipient != address(0), "Invalid address");
      require(amount > 0, "Invalid amount");
      require(transfer(recipient, amount), "Transfer failed");
      require(IRecipient(recipient).tokenReceived(msg.sender, amount), "Transfer callback failed");
   }
}
```

需要注意的是，`tokenReceived()` 函数不执行转账操作，所以在调用之前，需要先通过 `transfer()` 函数完成转账。

### 二、ERC721 篇

这一部分要实现 ERC721 合约的发行，以及 NFT 的铸造。

#### 1. MyERC721 合约

在 [MyERC721.sol](./contracts/ERC721/MyERC721.sol) 中实现继承和铸造的功能。

##### 1.1 继承合约

```solidity
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC20 {}
```

在以上代码中，我们继承了 `URIStorage` 合约，来接收 NFT 的 URI，并使用 `_safeMint()` 函数铸造 NFT。也导入了 Counters 库来使用其中控制数值的方法。

##### 1.2 构造函数

```solidity
   constructor() ERC721("Corror's Token", "CRT") {}
```

在构造函数中，向 ERC721 的构造函数提供 `name` 和 `symbol` 来初始化 NFT 合约。

##### 1.3 铸造函数

```solidity
   using Counters for Counters.counter;
   Counters.counter private _tokenId;

   safeMint(address to, string memory tokenURI) external returns(uint256) {
      uint256 newTokenId = _tokenIds.current();

      _safeMint(to, newTokenId);
      _setTokenURI(newTokenId, tokenURI);

      _tokenIds.increment();

      return newTokenId;
   }
```

以上代码包含了多个新的概念：
- `using Counters for Counters.counter`: 将 `Counters` 库中的方法，添加到 `Counters.counter` 结构体中，时期能直接调用库中的方法。
- `Counters.counter private _tokenId`: 让 `tokenId` 具备了 `Counter.counter` 中的方法。
- `_safeMint()` 执行了 `_mint()` 和 `_checkOnERC721Received()` 函数，其中：
  - `_mint()` 函数本质上是在做 `balances[to] += 1` 和 `owners[tokenId] = to` 这两步。
  - `_checkOnERC721Received()` 方法是在检查 NFT 是否被成功铸造。

其中，之所以不将 `_tonkenIds.increment()` 与 `return` 语句合并为 `return _tokenIds.increment() - 1`, 是因为状态更新和返回值分开能够更加清晰地展现合约逻辑。

#### 2. 铸造NFT

##### 2.1 获得图片 URI

将图片上传到 [Pinata](https://www.pinata.cloud/) 获得 URI.

##### 2.2 完善元数据

```json
{
    "title": "白鹿",
    "description": "一张我很喜欢的头像",
    "image": "ipfs://QmReVde9YWmZj142wS55fk57YMar2iSsRUj3dU9aDwwYZo",
    "attributes": [
        {
            "trait_type": "颜色",
            "value": "白色"
        },
        {
            "trait_type": "种类",
            "value": "鹿"
        }
    ]
}
```

将元数据写成 [metadata.json](./metadata/metadata.json) 文件，需要包括：`title`, `description`, `image` 和 `attributes` 属性。

`attributes` 的格式可以参考 [Opensea 的文档](https://docs.opensea.io/docs/metadata-standards#attributes)。

##### 2.3 获得元数据 URI

将元数据的 Json 文件上传到 Pinata, 获得元数据的 URI

##### 2.4 铸造 NFT

将地址和 URI 填写至 [safeMint 函数](https://goerli.etherscan.io/address/0x2da4dde492ead5af5480ad020600a29791382e15#writeContract#F2)，开始铸造 NFT.

##### 2.5 查看 NFT

在 Opensea 中查看自己的 [Collection](https://testnets.opensea.io/collection/corror-s-nfts) 和[刚刚铸造的 NFT](https://testnets.opensea.io/assets/goerli/0x2da4dde492ead5af5480ad020600a29791382e15/0).

### 三、NFTMarket 篇

在 [NFTMarket.sol](./contracts/ERC721/NFTMarket.sol) 中实现上架、购买和交易确认功能。

#### 1. 合约继承

```solidity
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarket is IERC721Receiver {}
```

NFTMarket 合约需要继承 IERC721Receiver 接口，以便能正确执行 `_safeTransfer()` 函数。

#### 2. 构造函数

方法一：

```solidity
   address private _erc20ContractAddress;
   address private _erc721ContractAddress;

   constructor(address erc20ContractAddress, address erc721Contractaddress) {
      _erc20ContractAddress = erc20ContractAddress;
      _erc721ContractAddress = erc721ContractAddress;
   }

   function getERC20ContractAddress() external view returns(address) {
      return _erc20ContractAddress;
   }

   function getERC721ContractAddress() external view returns(address) {
      return _erc721ContractAddress;
   }
```

方法二：

```solidity
   address public immutable erc20ContractAddress;
   address public immutable erc721ContractAddress;

   constructor(address _erc20ContractAddress, address _erc721ContractAddress) {
      erc20ContractAddress = _erc20ContractAddress;
      erc721ContractAddress = _erc721ContractAddress;
   }
```

对比这两种方法来看，两种方法在访问权限上是相似的，都是只读，不同的地方在于：
- 方法一：合约地址的封装性更好，在将来有可以修改的扩展性，但是代码相对冗余。
- 方法二：合约地址不具备修改的可能性，但是代码更加简洁。

从我们的应用场景上看，使用方法二是更好的选择。

#### 3. 交易确认

```solidity
   function onERC721Received(
      address operator,
      address from,
      uint256 tokenId,
      bytes calldata data
   ) external override returns (bytes4) {
      return this.onERC721Received.selector;
   }
```

为什么要在 NFTMarket 中实现 `onERC721Received()` 函数？
- `safeTransferFrom()` 函数会嵌套调用以下函数：
  1. `_safeTransfer()`
  2. `_checkOnERC721Received()`
  3. `onERC721Received()`
- 而最后的 `onERC721Received()` 需要在 `to` 合约中实现。

#### 4. NFT 上架

```solidity
   mapping(uint256 => uint256) private _tokenIdToPrice;

   function listNFTForSale(uint256 tokenId, uint256 price) external {
      require(price > 0, "Invalid price");
      IERC721(erc721TokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);
      _tokenIdToPrice[tokenId] = price;
   }

   function getTokenPrice(uint256 tokenId) external view returns(uint256) {
      return _tokenIdToPrice[tokenId];
   }
```

这里调用了 `safeTransferFrom` 来将代币从从用户手中转移到当前合约。

#### 5. NFT 购买

```solidity
   function buyNFT(uint256 tokenId) external {
      uint256 price = _tokenIdToPrice[tokenId];
      
      require(price > 0, "Not for sale");
      require(IERC721(erc721ContractAddress).ownerOf(tokenId) == address(this), "NFT is not available");

      _tokenIdToPrice[tokenId] = 0;

      require(IERC20(erc20ContractAddress).transferFrom(msg.sender, address(this), price), "ERC20 token transfer failed");
      IERC721(erc721ContractAddress).safeTransferFrom(address(this), msgsender, tokenId);
   }
```

注意，在购买 NFT 的函数中，需要多判断一次当前 NFT 的所有权是否归当前合约所有。