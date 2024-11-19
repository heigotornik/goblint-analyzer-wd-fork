// PARAM: --set "ana.activated[+]" signs 
// Fully context-insensitive
#include <goblint.h>
#include <pthread.h>

int g = 0;
int h = 0;
int j = 0;


void *t_foo1(void *arg) {
  if (g == 1) {
     h = 1;
  }
}

void *t_foo2(void *arg) {
  if (g == 1) {
     h = 2;
     j = 1;
  }

}

int main() {
  int x, y, z, ks;
  int k = 90;
  
  pthread_t id;
  pthread_create(&id, NULL, t_foo1, NULL);
  pthread_create(&id, NULL, t_foo2, NULL);

  int a = 1;  // effecting threads = {}
  g = 1;
  int f = 22; // effecting threads = {}
  int p = 40; // effecting threads = {}
  int o = 21; // effecting threads = {}
  x = h;      // effecting threads = {t_foo1, t_foo2}
  int e = 5;  // effecting threads = {}
  y = h;      // effecting threads = {t_foo1, t_foo2}
  z = j;      // effecting threads = {t_foo2}
  ks = h;

  // NOCRASH
  return 0;
}
