#include <inttypes.h>
#include <stdio.h>
#include <string.h>

int int_add_128(uint32_t *r, const uint32_t *a, const uint32_t *b);

void int_print(const char *c, uint32_t *a, int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) printf("%s", c);
  for (i = len - 1; i >= 0; i --) printf("%08x", a[i]);
  printf("\n");
}

int main(void)
{
  int c = 5;
  unsigned int a[4] = { 10, 20, 30, 40 };
  unsigned int b[4] = { 11, 22, 33, 44 };
  unsigned int r[4];
  
  c = int_add_128(r, a, b);
  
  int_print("a = 0x", a, 4);
  int_print("a = 0x", b, 4);
  int_print("a = 0x", r, 4);
  printf("c = %i\n", c);
  
  return 0;
}

