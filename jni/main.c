#include <stdio.h>

#include <jni.h>

#ifdef __arm__
int asm_main(void);
#endif

jstring Java_com_cyrille_assemblytest_MainActivity_jniMethod(
        JNIEnv* env, jobject thiz) {
    enum Constexpr { N = 256 };
    char s[N];
    size_t cur = 0;

    int x = 0;
#ifdef __arm__
    cur += snprintf(s + cur, N - cur, "arm ");
    /* Inline test. Increment x by 1. */
    /* asm (
        "add %0, #1"
        : "=r" (x)
        : "0" (x)
    );*/
    /* Separate source test. Increment x by 1. */

    x += asm_main();
#endif

    if (x == 1)
        cur += snprintf(s + cur, N - cur, "%s", "1");
    else
        cur += snprintf(s + cur, N - cur, "%s", "-");

    cur += snprintf(s + cur, N - cur, "Hello %d", x);
    /*cur += snprintf(s + cur, N - cur, "Hello %d", asm_main());*/

    return (*env)->NewStringUTF(env, s);
}