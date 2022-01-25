#include <stdio.h>
#include <stdint.h>

typedef struct st_list_node {
    struct st_list_node *next;
    size_t item_size;
    char data[0];
} list_node;

typedef struct {
    list_node *head;
    size_t phantom_item_size;
} linked_list;

extern void list_init(linked_list *list);
extern void list_push_back(linked_list *list, void *item, size_t item_size);
extern size_t list_length(linked_list *list);
extern void list_traverse(linked_list *list, void (*callback)(void *item, size_t item_size, void *ctx), void *ctx);
extern void list_drop(linked_list *list);

void summarize_size(void *item, size_t item_size, void *ctx) {
    (void)item;
    *(size_t*)ctx += item_size;
}

int main() {
    linked_list list;

    list_init(&list);
    list_push_back(&list, "hello", 6);
    list_push_back(&list, "world", 6);
    list_push_back(&list, "holyshit", 9);

    printf("%zu\n", list_length(&list));

    size_t size = 0;
    list_traverse(&list, summarize_size, &size);
    printf("%zu\n", size);
}
