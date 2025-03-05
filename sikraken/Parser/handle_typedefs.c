#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void* safe_malloc(size_t);
extern int debugMode;

typedef struct node {
	int is_typedef_name;	//the id represents a TYPEDEF_NAME (and not an IDENTIFIER shadowing it)
	char* name;				//the name of the id
	struct node* next;
} list_node;

void free_list_node(list_node* node) {
	while (node != NULL) {
		list_node* temp = node;
		node = node->next;
		free(temp->name);
		free(temp);
	}
}

typedef struct scope_node {
	int scope_nb;
	list_node* typedef_list;
	struct scope_node* below;
} scope_node;
scope_node* scope_stack = NULL;

void print_scope_stack() {
	scope_node* current_scope = scope_stack;
	if (current_scope == NULL) {
		printf("Scope stack is empty\n");
		return;
	}
	while (current_scope != NULL) {
		printf("Scope %d:\n", current_scope->scope_nb);
		list_node* current_typedef_node = current_scope->typedef_list;
		while (current_typedef_node != NULL) {
			printf("\t%s is a %s\n", current_typedef_node->name, (current_typedef_node->is_typedef_name ? "TYPEDEF_NAME" : "shadow IDENTIFIER"));
			current_typedef_node = current_typedef_node->next;
		}
		current_scope = current_scope->below;
	}
}

void push_scope(int scope_nb) {
	scope_node* new_scope_node = (scope_node *)safe_malloc(sizeof(scope_node));
	new_scope_node->scope_nb = scope_nb;
	new_scope_node->typedef_list = NULL;
	if (scope_stack != NULL) new_scope_node->below = scope_stack;
	else new_scope_node->below = NULL;
	scope_stack = new_scope_node;
	if (debugMode) printf("Pushed scope %d\n", scope_nb);
}

//only pop the top scope if its scope number matches the given scope number
void pop_scope(int *scope_nb) {
	if (scope_stack != NULL && scope_stack->scope_nb == *scope_nb) {
		scope_node* top_scope = scope_stack;
		scope_stack = scope_stack->below;
		free_list_node(top_scope->typedef_list);
		free(top_scope);
		if (debugMode) printf("Popped scope %d\n", *scope_nb);
	}
	(*scope_nb)--;
}

void add_typedef_id(int scope, char* id, int is_typedef_name) {
	if (scope_stack == NULL || scope_stack->scope_nb != scope) {
		//a new scope is needed because either none exist yet or it is for a new scope
		push_scope(scope);
	}

	if (!strncmp(id, "UC_", 3)) id = &id[3];	//removing the "UC_"  prefix before adding to collection of typedef
	else id[0] = tolower(id[0]);	//lowering the first letter before adding to collection of typedef
	list_node* new_node = (list_node *)safe_malloc(sizeof(list_node));	
	new_node->is_typedef_name = is_typedef_name;
	new_node->name = (char*)safe_malloc(strlen(id) + 1);
	strcpy_safe(new_node->name, strlen(id) + 1, id);
	if (scope_stack->typedef_list != NULL) new_node->next = scope_stack->typedef_list;	//adding the new node to the front of the list
	else new_node->next = NULL;
	scope_stack->typedef_list = new_node;
	if (debugMode) printf("Added %s as a %s to typedef list\n", id, (is_typedef_name ? "TYPEDEF_NAME" : "shadow IDENTIFIER"));
}

//look for the id in the scope of list of typedefs
int is_typedef_name(char* id) {
	if (debugMode) {
		printf("Looking for %s in typedef list\n", id);
		print_scope_stack();
	}
	scope_node* current_scope = scope_stack;
	while (current_scope != NULL) {
		list_node* current_typedef_node = current_scope->typedef_list;
		while (current_typedef_node != NULL) {
			if (current_typedef_node->is_typedef_name && !strcmp(current_typedef_node->name, id)) {	//a matching node representing a typedef_name has been found 
				return 1;
			}
			current_typedef_node = current_typedef_node->next;
		}
		current_scope = current_scope->below;
	}
	return 0;
}

