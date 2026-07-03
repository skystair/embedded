#include <stdio.h>

int main(char argc, char **argv){
    
    printf("out_arm_hello~\r\n");
    printf("argc = %d\r\n", argc);
    
    for(int i = 0; i < argc; i++){
        printf("argv[%d] = %s\r\n", i, argv[i]);
    }
    return 0;
}
//push commit test2