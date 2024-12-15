all:
	$(MAKE) -C tutorial

clean:
	$(MAKE) -C tutorial/part1 clean
	$(MAKE) -C tutorial/part2 clean
	$(MAKE) -C tutorial/part3 clean
	$(MAKE) -C tutorial/part4 clean
	$(MAKE) -C tutorial/part5 clean
fmt:
	$(MAKE) -C tutorial/part1 fmt
	$(MAKE) -C tutorial/part2 fmt
	$(MAKE) -C tutorial/part3 fmt
	$(MAKE) -C tutorial/part4 fmt
	$(MAKE) -C tutorial/part5 fmt
