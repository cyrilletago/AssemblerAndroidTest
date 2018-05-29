#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <jni.h>

#ifdef __ARM__

int int_add_128(uint32_t *r, const uint32_t *a, const uint32_t *b);
void int_mul_128(uint32_t *r, const uint32_t *a, const uint32_t *b);
void int_mul_192(uint32_t *r, const uint32_t *a, const uint32_t *b);
void int_mul_256(uint32_t *r, const uint32_t *a, const uint32_t *b);

void gfp_mul_128(uint32_t *r, const uint32_t *a, const uint32_t *b, uint32_t c);
void gfp_mul_192(uint32_t *r, const uint32_t *a, const uint32_t *b, uint32_t c);
void gfp_mul_256(uint32_t *r, const uint32_t *a, const uint32_t *b, uint32_t c);

void gfp_sqr_128(uint32_t *r, const uint32_t *a, uint32_t c);
void gfp_sqr_192(uint32_t *r, const uint32_t *a, uint32_t c);
void gfp_sqr_256(uint32_t *r, const uint32_t *a, uint32_t c);

#endif
void int_print(const char *c, uint32_t *a, int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) printf("%s", c);
  for (i = len - 1; i >= 0; i --) printf("%08x", a[i]);
  printf("\n");
}

jstring Java_com_cyrille_assemblytest_MainActivity_jniMethod(
        JNIEnv* env, jobject thiz) {

  enum Constexpr { N = 256 };
      char s[N];
      size_t cur = 0;

      int x = 0;

  // int c = 5;
  // unsigned int a[4] = { 10, 20, 30, 40 };
  // unsigned int b[4] = { 11, 22, 33, 44 };
  // unsigned int r[4];

  int c = 0;
  unsigned int a[4] = { 0xa3a2a1a0, 0xa7a6a5a4, 0xabaaa9a8, 0xafaeadac };
  unsigned int b[4] = { 0xb3b2b1b0, 0xb7b6b5b4, 0xbbbab9b8, 0xbfbebdbc };
  unsigned int r[8];

  #ifdef __ARM__

    c = int_add_128(r, a, b);

      // int_print("a = 0x", a, 4);
      // int_print("a = 0x", b, 4);
      // int_print("a = 0x", r, 4);
      // printf("c = %i\n", c);
  #endif
   cur += snprintf(s + cur, N - cur, "operand a: %08x%08x%08x%08x\n", a[3], a[2], a[1], a[0]);
   cur += snprintf(s + cur, N - cur, "operand b: %08x%08x%08x%08x\n", b[3], b[2], b[1], b[0]);
   cur += snprintf(s + cur, N - cur, "carry: %d, result: %08x%08x%08x%08x", c, r[3], r[2], r[1], r[0]);
   /*cur +=a snprintf(s + cur, N - cur, "Hello %d", asm_main());*/

  #ifdef __ARM__

    int_mul_128(r, a, b);
  #endif

   cur += snprintf(s + cur, N - cur, "operand a: %08x%08x%08x%08x\n", a[3], a[2], a[1], a[0]);
   cur += snprintf(s + cur, N - cur, "operand b: %08x%08x%08x%08x\n", b[3], b[2], b[1], b[0]);
   cur += snprintf(s + cur, N - cur, "result: %08x%08x%08x%08x%08x%08x%08x%08x", r[7], r[6], r[5], r[4], r[3], r[2], r[1], r[0]);


  #ifdef __ARM__

     gfp_mul_128(r, a, b, 91);
  #endif

   cur += snprintf(s + cur, N - cur, "operand a: %08x%08x%08x%08x\n", a[3], a[2], a[1], a[0]);
   cur += snprintf(s + cur, N - cur, "operand b: %08x%08x%08x%08x\n", b[3], b[2], b[1], b[0]);
   cur += snprintf(s + cur, N - cur, "result: %08x%08x%08x%08x", r[3], r[2], r[1], r[0]);
   // correct result according to Magma:
   // 0x40E6B35C981B9CD16F2BBCD83384C288
  #ifdef __ARM__

     gfp_sqr_128(r, a, 91);
  #endif

   cur += snprintf(s + cur, N - cur, "operand a: %08x%08x%08x%08x\n", a[3], a[2], a[1], a[0]);
   cur += snprintf(s + cur, N - cur, "result: %08x%08x%08x%08x", r[3], r[2], r[1], r[0]);
    // correct result according to Magma:
    // 0x4D8B4B4328B193843968C80CED1E9268
   return (*env)->NewStringUTF(env, s);

}

