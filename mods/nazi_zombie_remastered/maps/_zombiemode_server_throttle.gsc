#include maps\_utility; 

server_choke_init( id, max )
{
	if ( !IsDefined( level.zombie_server_choke_ids_max ) )
	{
		level.zombie_server_choke_ids_max = [];
		level.zombie_server_choke_ids_count = [];
	}

	level.zombie_server_choke_ids_max[ id ] = max;
	level.zombie_server_choke_ids_count[ id ] = 0;

	level thread server_choke_thread( id );
}


server_choke_thread( id )
{
	while( 1 )
	{
		wait( 0.05 );
		level.zombie_server_choke_ids_count[ id ] = 0;
	}
}


server_choke_safe( id )
{
	return( level.zombie_server_choke_ids_count[ id ] < level.zombie_server_choke_ids_max[ id ] );
}


server_choke_action( id, choke_action, arg1, arg2, arg3 )
{
	AssertEx( IsDefined( level.zombie_server_choke_ids_max[ id ] ), "server Choke: " + id + " undefined" );

	while( !server_choke_safe( id ) )
	{
		wait( 0.05 );		
	}

	level.zombie_server_choke_ids_count[ id ]++;

	if ( !IsDefined( arg1 ) )
	{
		return ( [[choke_action]]() );
	}

	if ( !IsDefined( arg2 ) )
	{
		return ( [[choke_action]]( arg1 ) );
	}
	
	if ( !IsDefined( arg3 ) )
	{
		return ( [[choke_action]]( arg1, arg2 ) );
	}
	
	return ( [[choke_action]]( arg1, arg2, arg3 ) );
}


server_entity_valid( entity )
{
	if( !IsDefined( entity ) )
	{
		return false;
	}
	
	return true;
}


server_safe_init( id, max )
{
	if ( !IsDefined( level.zombie_server_choke_ids_max ) || !IsDefined( level.zombie_server_choke_ids_max[ id ] ) )
	{
		server_choke_init( id, max );
	}

	assert( max == level.zombie_server_choke_ids_max[ id ] );
}

_server_safe_ground_trace( pos )
{
	return groundpos( pos );
}

server_safe_ground_trace( id, max, origin )
{
	server_safe_init( id, max );
	return( server_choke_action( id, ::_server_safe_ground_trace, origin ) );
}