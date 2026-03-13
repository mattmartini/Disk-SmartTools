# Disk::SmartTools Roadmap

Plans for the development of Disk::SmartTools

Improvements inspired by [SMART Disk Monitoring for Prometheus]( https://github.com/micha37-martins/S.M.A.R.T-disk-monitoring-for-Prometheus )

v3.4.0

3.4 - Get smartctl version

3.5 - Check if disk is active (smartctl -n standby <disk>)

3.6 - Use --scan-open to find list of disks

3.7 - Get device type

4.0 - Gather information via json

    - smart_show.pl - Don't quit after reporting once.

4.1 - Find information on nvme devices

4.2 - Seagate specific extensions

4.3 - Program for dumping information in Grafana Prometheus format
 
