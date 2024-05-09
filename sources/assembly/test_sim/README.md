# Test Code

包含 8 个 .asm 和对应的 .coe，为初步测试 CPU 正确性的文件



| 测试  | 内容                                           | 结果 |
| ----- | ---------------------------------------------- | ---- |
| test1 | 测试 `lb` 和 `sb`，拨动拨码开关对应 Led 灯亮起 |      |
| test2 | 测试前递单元                                   |      |
| test3 | 测试数据冒险停顿                               |      |
| test4 | 测试分支跳转                                   |      |
| test5 | 使用循环测试分支预测                           |      |
| test6 | 测试叶子方法的调用                             |      |
| test7 | 通过递归测试非叶子方法的调用(fib)                |      |
| test8 | 通过 ecall 测试异常                            |      |
| test9 | 测试 DCache 写回功能                           ｜     ｜