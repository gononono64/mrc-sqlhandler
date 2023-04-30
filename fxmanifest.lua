
fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."


shared_scripts {    
    --'config.lua',
	'shared/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

dependencies {
	'oxmysql'
}

