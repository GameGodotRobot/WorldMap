extends Node

## region
@warning_ignore("unused_signal")
signal region_node__region_click(country_id, region_id);

## country
@warning_ignore("unused_signal")
signal country_node__select_country(country_id);
@warning_ignore("unused_signal")
signal country_node__select_region(region_id);
@warning_ignore("unused_signal")
signal country_node__deselect_country(country_id);
@warning_ignore("unused_signal")
signal country_node__deselect_region(region_id);

## camera
@warning_ignore("unused_signal")
signal camera__zoom_change(zoom);
@warning_ignore("unused_signal")
signal camera__position_change(position);

## splash screen
@warning_ignore("unused_signal")
signal spash_screens__start;
@warning_ignore("unused_signal")
signal spash_screens__end;

## Map
@warning_ignore("unused_signal")
signal map__click;

## Interface
@warning_ignore("unused_signal")
signal interface__next_day;
