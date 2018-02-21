#include <stdio.h>

#include <jni.h>
/* This stub calls the function. */

#ifdef __ARM__
int asm_main(void);
int add_asm(int a, int b);
#endif

jstring Java_com_cyrille_assemblytest_MainActivity_jniMethod(
        JNIEnv* env, jobject thiz) {
    enum Constexpr { N = 256 };
    char s[N];
    size_t cur = 0;

    int x = 0;

#ifdef __ARM__
    /* This part of the code seems not to be executed as the value of x in the if loop
         * remains 0 even after the redefinition below.*/

    // cur += snprintf(s + cur, N - cur, "arm ");

    x = 1;

    x += asm_main();
    x += add_asm(1000, 4000);
#endif


//    if (x == 1)
//        cur += snprintf(s + cur, N - cur, " Hello: x is %s", "1");
//    else
//        cur += snprintf(s + cur, N - cur, " Hello: x is %s", "-");

    cur += snprintf(s + cur, N - cur, " Hello %d", x);
    /*cur +=a snprintf(s + cur, N - cur, "Hello %d", asm_main());*/

    return (*env)->NewStringUTF(env, s);
}