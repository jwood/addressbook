deploy:
	rsync -avz --exclude=.git . ec2-user@hasan.d8u.us:addressbook/ 

patch:
	rsync -avz --exclude=.git ec2-user@hasan.d8u.us:addressbook/ .
	git add -A
	
