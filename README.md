# Enumivo Auto Claim bash script
* I recommend to use this script outside your BP node. If so I fully recommend to
do it over a secured connection since you have to send your wallet's pass to your
BP (or any other BP) node to be processed.

The sript will help you claim your ENU coins once a day. It gets executed once a
day by cron and it stays in a loop checking if the claim is possible. After it's
done all tokens from your wallet get staked automatically 50% to CPU and 50% to
network.
