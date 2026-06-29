# 练习2：读入一个整数，打印它
.data
    prompt:  .asciiz "Input an integer: "
    result:  .asciiz "You entered: "
    newline: .asciiz "\n"
    
.text
.globl main
main:
    # 打印提示语
    li   $v0, 4
    la   $a0, prompt
    syscall

    # 读入整数 → 结果自动放进 $v0
    li   $v0, 5          # 系统调用号 5 = 读整数
    syscall
    move $t0, $v0        # 把读到的数存入 $t0 保存好

    # 打印 "你输入的是: "
    li   $v0, 4
    la   $a0, result
    syscall

    # 打印那个整数
    li   $v0, 1          # 系统调用号 1 = 打印整数
    move $a0, $t0        # 把数放进 $a0
    syscall

    # 换行
    li   $v0, 4
    la   $a0, newline
    syscall

    # 退出
    li   $v0, 10
    syscall