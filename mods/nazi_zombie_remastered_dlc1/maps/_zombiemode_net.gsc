#include maps\_utility; 

network_choke_init( id, max )
{
	if ( !IsDefined( level.zombie_network_choke_ids_max ) )
	{
		level.zombie_network_choke_ids_max = [];
		level.zombie_network_choke_ids_count = [];
	}

	level.zombie_network_choke_ids_max[ id ] = max;
	level.zombie_network_choke_ids_count[ id ] = 0;

	level thread network_choke_thread( id );
}


network_choke_thread( id )
{
	while( 1 )
	{
		wait_network_frame();
		wait_network_frame();
		level.zombie_network_choke_ids_count[ id ] = 0;
	}
}


network_choke_safe( id )
{
	return( level.zombie_network_choke_ids_count[ id ] < level.zombie_network_choke_ids_max[ id ] );
}


network_choke_action( id, choke_action, arg1, arg2, arg3 )
{
	AssertEx( IsDefined( level.zombie_network_choke_ids_max[ id ] ), "Network Choke: " + id + " undefined" );

	while( !network_choke_safe( id ) )
	{
		wait( 0.05 );		
	}

	level.zombie_network_choke_ids_count[ id ]++;

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


network_entity_valid( entity )
{
	if( !IsDefined( entity ) )
	{
		return false;
	}
	
	return true;
}


network_safe_init( id, max )
{
	if ( !IsDefined( level.zombie_network_choke_ids_max ) || !IsDefined( level.zombie_network_choke_ids_max[ id ] ) )
	{
		network_choke_init( id, max );
	}

	assert( max == level.zombie_network_choke_ids_max[ id ] );
}


// SPAWNING
_network_safe_spawn( classname, origin )
{
	return Spawn( classname, origin );
}


network_safe_spawn( id, max, classname, origin )
{
	network_safe_init( id, max );
	return ( network_choke_action( id, ::_network_safe_spawn, classname, origin ) );
}


// FX
_network_safe_play_fx_on_tag( fx, entity, tag )
{
	if ( network_entity_valid( entity ) )
	{
		PlayFxOnTag( fx, entity, tag );
	}
}


network_safe_play_fx_on_tag( id, max, fx, entity, tag )
{
	network_safe_init( id, max );
	network_choke_action( id, ::_network_safe_play_fx_on_tag, fx, entity, tag );
}

_network_safe_stalingrad_spawn( spawner )
{
	return spawner stalingradspawn();
}

network_safe_stalingrad_spawn( id, max )
{
	network_safe_init( id, max );
	return( network_choke_action( id, ::_network_safe_stalingrad_spawn, self ) );
}
