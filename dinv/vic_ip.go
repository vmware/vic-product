package main

import "net"

// This method will check if the vicIP is qualified FQDN or IP address
// it will return IP address if FQDN is input
// return nil if non qualified fqdn or ip address is input
func check_vic_ip(vicIP string) (net.IP, error) {
	var ip_addr net.IP
	if vicIP != "" {
		ip_addr = net.ParseIP(vicIP)
		if ip_addr == nil {
			ips, err := net.LookupIP(vicIP)
			if err != nil {
				return nil, err
			}
			return net.ParseIP(ips[0].String()), nil
		}
	} else {
		ip, err := getFirstIP("eth0")
		if err != nil {
			return nil, err
		}
		ip_addr = ip
	}
	return ip_addr, nil
}
