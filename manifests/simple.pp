# ex:ts=4 sw=4 tw=72

class shorewall::simple (
	$ipv4         = $shorewall::params::ipv4,
	$ipv6         = $shorewall::params::ipv6,
	$inet         = 'inet',
	$ipv4_tunnels = false,
	$ipv6_tunnels = false,
) inherits shorewall::params {

	class { 'shorewall::multi':
		ipv4         => $ipv4,
		ipv6         => $ipv6,
		ipv4_tunnels => $ipv4_tunnels,
		ipv6_tunnels => $ipv6_tunnels,
	}

	define iface (
		$ipv4    = $shorewall::simple::ipv4,
		$ipv6    = $shorewall::simple::ipv6,
		$dynamic = false,
	) {
		shorewall::multi::iface { $name:
			ipv4    => $ipv4,
			ipv6    => $ipv6,
			options => $dynamic ? [ 'tcpflags', 'nosmurfs', 'routefilter', 'dhcp', 'optional' ] : [ 'tcpflags', 'nosmurfs', 'routefilter' ],
			zone    => $shorewall::simple::inet,
		}
	}

	define port (
		$proto,
		$port,
	) {
		shorewall::multi::port { $name:
			proto  => $proto,
			port   => $port,
			source => $shorewall::simple::inet,
		}
	}

	define tunnel (
		$proto   = 'ipv4',
		$type,
		$gateway = '0.0.0.0/0',
	) {
		shorewall::multi::tunnel { $name:
			proto   => $proto,
			type    => $type,
			gateway => $gateway,
			zone    => $shorewall::simple::inet,
		}
	}

	shorewall::multi::zone { $inet: }

	shorewall::multi::policy { "policy-drop-$inet-to-local":
		priority => '10',
		source   => $inet,
		dest     => '$FW',
		action   => 'DROP',
	}
}
