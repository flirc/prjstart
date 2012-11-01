BEGIN {
	FS="[ \t]*,[ \t]*";
	TARGETS="";
}

/^[^#]/ {
	if(NF == 3 && length($1)) {
		TARGETS = TARGETS " " $1;
		printf("%s : %s\n", $1, $2);
		if(length($3)) {
			printf("\t$(Q)%s\n", $3);
		}
		printf("\n");
	}
}

END {
	printf("TARGET_LIST :=%s\n", TARGETS);
}
