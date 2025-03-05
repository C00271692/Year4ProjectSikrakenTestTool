#include <stdio.h>

// Function to modify an array
void modifyArray(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        arr[i] += 10; // Add 10 to each element
    }
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);

    printf("Original array: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", numbers[i]);
    }
    printf("\n");

    modifyArray(numbers, size); // Pass the array to the function

    printf("Modified array: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", numbers[i]);
    }
    printf("\n");

    return 0;
}