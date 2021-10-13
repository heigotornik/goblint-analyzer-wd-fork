// PARAM: --set sem.int.signed_overflow assume_none --disable ana.int.def_exc --enable exp.annotated.precision --set ana.int.refinement fixpoint
int main() __attribute__((precision("interval","congruence"))) {
    // A refinement of a congruence class should only take place for the == and != operator.
    int i;
    if (i==0){
      assert(i==0);
    } else {
      assert(i!=0); //UNKNOWN
    }

    int k;
    if (k > 0) {
      assert (k > 0);
    } else {
      assert (k <= 0);
    }

    return 0;
}
