#include <stdint.h>
#include <stdio.h>

typedef enum e_tree_kind {
    VALUE = 0,
    SUM = 1,
    SUBTRACTION = 2,
    MULTIPLICATION = 3,
    DIVISION = 4
} tree_kind;

typedef struct st_tree_node_base {
    int64_t metadata;
} tree_node_base;

typedef struct st_tree_node {
    int64_t operator;
    tree_node_base *lhs;
    tree_node_base *rhs;
} tree_node;

typedef struct st_tree_leaf {
    int64_t leaf_kind;
    int64_t value;
} tree_leaf;

int64_t evaluate(tree_node_base *base, int64_t *error);

int main() {
    tree_leaf left = (tree_leaf) { VALUE, 114 };
    tree_leaf right = (tree_leaf) { VALUE, 514 };
    tree_node sum = (tree_node) {
        SUM,
        (tree_node_base*)&left,
        (tree_node_base*)&right
    };

    tree_leaf left2 = (tree_leaf) { VALUE, 1919 };
    tree_leaf right2 = (tree_leaf) { VALUE, 810 };
    tree_node mul = (tree_node) {
        MULTIPLICATION,
        (tree_node_base*)&left2,
        (tree_node_base*)&right2
    };

    tree_node div = (tree_node) {
        DIVISION,
        (tree_node_base*)&mul,
        (tree_node_base*)&sum
    };

    int64_t err;
    printf("result = %lld\n", evaluate((tree_node_base*)&div, &err));
    printf("err = %lld\n", err);
}
