**# Ethereum_iOS**

移动端的智能合约接口

在调用合约编码接口时

1.先调用方法原型编码方法

```- (NSString *)encodeFunction:(NSString *)function 
- (NSString *)encodeFunction:(NSString *)function 
```

参数格式参考demo

2.再调用

```
- (NSString *)payloadWithFunction:(NSString *)funcCode andArgs:(NSArray *)args
```

其中args参数格式`类型 + 值`参考 

```
@[@"string SleepPerformer", @"bool YES"]
```

  在Demo中，对参数类型为array的操作可能存在bug