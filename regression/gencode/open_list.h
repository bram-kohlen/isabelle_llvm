// Generated by Isabelle-LLVM. Do not modify.
#ifndef _OPEN_LIST_H
#define _OPEN_LIST_H 1



typedef struct list_elem list_elem;
typedef struct pop_result pop_result;

typedef list_elem* os_list;
typedef struct list_elem {
  uint64_t data;
  list_elem*next;
} list_elem;
typedef struct pop_result {
  uint64_t data;
  list_elem*list;
} pop_result;

list_elem* os_rem(int64_t, list_elem*);
void os_pop(os_list, pop_result*);
os_list os_empty();
os_list os_prepend(int64_t, os_list);
list_elem* os_reverse(list_elem*);
char os_is_empty(os_list);

#endif
