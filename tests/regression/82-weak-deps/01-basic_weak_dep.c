// PARAM: --set "ana.activated[+]" signs 
// Fully context-insensitive
#include <goblint.h>
#include <pthread.h>

int g = 0;
int h = 0;

void *t_foo(void *arg) {
  if (g == 1) {
     h = 1;
  }

}

int main() {
  int x, y;
  int k = 90;
  
  pthread_t id;
  pthread_create(&id, NULL, t_foo, NULL);
  int a = 1; // should not be re-evaluated 
  g = 1;
  int k = 22;
  int o = 21; // should be "aborted"
  x = h;     // should eval
  int e = 5; // should be "aborted"
  y = h;     
  // NOCRASH
  return 0;
}
