# Web3 项目仓库

这个仓库包含了我跟随登链社区 Web3 训练营学习技术过程中，完成的一系列实践项目。

## 目录

1. W1-1: 计数合约 Counter
    - 实现目标：在测试链上调用 Counter 合约的 add 函数，完成一次转账。
    - 专业知识：Solidity 函数声明。
    - 工具：Metamask, Remix, Goerli.
2. W1-2: Hardhat 计数合约
    - 实现目标：使用 Hardhat 测试、部署并验证 Counter 合约。
    - 专业知识：
        - Solidity 修饰器，
        - Chai 单元测试，
        - Hardhat run scripts 命令，
        - Hardhat verify 命令。
    - 工具：Goerli Etherscan.
3. W2-1: 金库合约 Bank
    - 实现目标：存储用户转入的 ETH, 记录转账用户和转账金额，允许合约所有者取出资金。
    - 专业知识：
        - Solidity:
            - receive() 函数
            - fallback() 函数
            - user[] 数组
            - for 循环
            - private 可见性
        - ethers.js
            - ethers.getSigner() 获取用户签名
            - ethers.getContractFactory("Bank") 获取合约工厂
        - JavaScript
            - Bank.deploy() 部署合约
            - bank.deployed() 确认合约
4. W2-2: 分数接口 IScore
    - 实现目标：让 Teacher 合约通过 IScore 接口访问并修改 Score 中的成绩。
    - 专业知识：
        - Solidity:
            - require() 错误处理
            - error() 错误处理
            - Interface 接口声明
            - modifier 修饰器
5. W3-1: ERC20 & ERC721 & NFTMarket
    - 实现目标：
        1. 发行 MyERC20 代币，允许 Bank 合约通过 ERC20 接口存储并提取该代币。
        2. 发布 MyERC721 合约，并通过该合约和自定义 URI 铸造 NFT。
        3. 发布 NFTMarket 合约，允许 MyERC20 代币与 MyERC721 中铸造的 NFT 进行交易。
    - 专业知识：
        - ERC20:
            - approve() 函数
            - transfer() 函数
            - transferFrom() 函数
            - Approve() 事件
            - Transfer() 事件
        - ERC777:
            - IRecipient 接口
            - tokenReceived 函数
        - ERC721:
            - safeTransfer() 函数
            - safeTransferFrom() 函数
            - approve() 函数
        - NFT:
            - metadata Json 格式
            - URI 生成
            - safeMint 铸造
        - NFTMarket:
            - onERC721Received() 函数
            - listTokenForSale() 函数
            - buyToken() 函数
        - openzeppelin:
            - Counters 库：
                - Counters.counter.increment() 方法
                - Counters.counter.current() 方法
            - IERC721Receiver 接口：防止 NFT 锁死
    - 工具：
        - @Openzeppelin/contracts
        - Opensea