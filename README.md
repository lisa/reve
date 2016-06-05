# Reve

[![Build Status](https://travis-ci.org/lisa/reve.svg?branch=master)](https://travis-ci.org/lisa/reve)

Reve is a library for the Eve Online API written in Ruby.

# Examples

The following are examples using the library.

## Convert player names to character IDs

    require 'reve'
    require 'pp'
    
    api = Reve::API.new
    
    ids = api.character_id( { :names => [ "CCP Garthagk" ] } )
    puts 'Names to IDs output:'
    pp names
    
    # Prints:
    names to IDs output
    [#<Reve::Classes::Character:0x4d98e55c
      @corporation_id=0,
      @corporation_name=nil,
      @id=797400947,
      @name="CCP Garthagk">]

# Contributing

Reve is in "maintenance mode." The author, [Lisa Seelye](https://github.com/lisa), is mostly hands-off and gladly accepts pull requests.

## Roadmap

In no specific order, this is a foreward looking list of items to be done for the project.

* Complete Implemented API Calls List
* Merge #17
* Implement missing API calls
* Reorganize code within the project

# Implemented API Calls

## Account

| Name | Method Name |
| -----| ------------|
| Account Status     | `account_status`    |
| API Key            | *Not Implemented* |
| List of Characters | `characters`        |


## Character

| Name | Method Name |
| -----| ------------|
| Account Balance          | `personal_wallet_balance` |
| Asset List               | `personal_assets_list` |
| Blueprints               | *Not Implemented* |
| Calendar Event Attendees | *Not Implemented* |
| Character Sheet          | `character_sheet` |
| Contact List             | `personal_contacts` |
| Contact Notifications    | *Not Implemented* |
| Contracts                | `contracts` |
| Contract Items           | *Not Implemented* |
| Contract Bids            | *Not Implemented* |
| Factional Warfare Stats  | `personal_faction_war_stats` |
| Industry Jobs            | `personal_industry_jobs` |
| Industry Jobs History    | *Not Implemented* |
| Kill Mails               | `personal_kills` (*deprecated*) |
| Locations                | *Not Implemented* |
| Mail Bodies              | `personal_mail_message_bodies` |
| Mailing Lists            | `personal_mailing_lists` |
| Mail Messages (Headers)  | `personal_mail_messages` |
| Market Orders            | `personal_market_orders` |
| Medals                   | `character_medals` |
| Notifications            | `personal_notifications` |
| Notification Texts       | *Not Implemented* |
| Planetary Colonies       | *Not Implemented* |
| Planetary Pins           | *Not Implemented* |
| Planetary Routes         | *Not Implemented* |
| Planetary Links          | *Not Implemented* |
| Research                 | `research` |
| Skill in Training        | `skill_in_training` |
| Skill Queue              | `skill_queue` |
| Standings (NPC)          | *Not Implemented* |
| Upcoming Calendar Events | `upcoming_calendar_events` |
| Wallet Journal           | `personal_wallet_journal` |
| Wallet Transactions      | `personal_wallet_transactions` |

## Corporation

| Name | Method Name |
| -----| ------------|
| Account Balances                  | `corporate_wallet_balance`  |
| Asset List                        | `corporate_assets_list` |
| Blueprints                        | *Not Implemented*  |
| Contact List                      | `corporate_contacts`  |
| Container Log                     | *Not Implemented*  |
| Contracts                         | *Not Implemented*  |
| Contract Items                    | *Not Implemented*  |
| Contract Bids                     | *Not Implemented*  |
| Corporation Sheet                 | `corporation_sheet`  |
| Customs Offices                   | *Not Implemented*  |
| Facilities                        | *Not Implemented*  |
| Factional Warfare Stats           | `corporate_faction_war_stats` |
| Industry Jobs                     | `corporate_industry_jobs`  |
| Industry Jobs History             | *Not Implemented*  |
| Kill Mails                        | `corporate_kills` (*deprecated*)  |
| Locations                         | *Not Implemented*  |
| Market Orders                     | `corporate_market_orders`  |
| Medals                            | `corporate_medals`  |
| Member Medals                     | `corporate_member_medals`  |
| Member Security                   | `corporate_member_security`  |
| Member Security Log               | *Not Implemented*  |
| Member Tracking                   | *Not Implemented*  |
| Outpost List                      | *Not Implemented*  |
| Outpost Service Detail            | *Not Implemented*  |
| Shareholders                      | *Not Implemented*  |
| Standings (NPC)                   | *Not Implemented*  |
| Starbase Details (POS)            | `starbase_details`  |
| Starbase list (POS)               | `starbases`  |
| Titles                            | *Not Implemented*  |
| Wallet Journal                    | `corporate_wallet_journal`  |
| Wallet Transactions               | `corporate_wallet_transactions`  | 

## Eve

| Name | Method Name |
| -----| ------------|
| Alliance List                   | `alliances`  | 
| Certificate Tree                | `certificate_tree` (*deprecated*)  |
| Character Affilication          | *Not Implemented*  |
| Character ID (name to id)       | `names_to_ids`  |
| Character Info                  | `character_info`  |
| Character Name (id to name)     | `ids_to_names`  |
| Conquerable Station List        | `conquerable_stations`  |
| Error list                      | `errors` |
| Factional Warfare Station       | `faction_war_stats`  |
| Factional Warfare Top 100 Stats | `faction_war_top_stats`  |
| RefTypes                        | `ref_types`  |
| Skill Tree                      | `skill_tree`  |
| Type Name                       | *Not Implemented*  |
 
## Map

| Name | Method Name |
| -----| ------------|
| Factional Warfare Systems (Occupancy map) | `faction_war_system_stats`  |
| Jumps                                     | `map_jumps`  |
| Kills                                     | `map_kills`  |
| Sovereignty                               | `sovereignty`  |

## Server

| Name | Method Name |
| -----| ------------|
| Server Status | `server_status`  | 

## API

| Name | Method Name |
| -----| ------------|
|  Call List (access mask ref) | *Not Implemented*  |
