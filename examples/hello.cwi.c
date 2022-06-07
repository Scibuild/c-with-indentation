
#include <stdio.h>

int factorial(int n) {
	int c = 1;
	for (int i = 1; i <= n; i ++){
		c *= i;}
	return c;
}
int main(int argv, char** argc) {
	printf("Hello world!\n");

	for (int i = 0; i < 10; i ++){
		printf("Count is %d\n", i);
}
	printf("10! is %d\n", factorial(10));
}
