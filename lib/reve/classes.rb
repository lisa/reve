#--
# Code copyright Lisa Seelye, 2007-2008. www.crudvision.com
# Reve is not licensed for commercial use. For other uses there are no
# restrictions.
#
# The author is not adverse to tokens of appreciation in the form of Eve ISK,
# ships, and feedback. Please use
# http://www.crudvision.com/reve-ruby-eve-online-api-library/ to provide
# feedback or send ISK to Raquel Smith in Eve. :-)
#++
module Reve #:nodoc:
  module Classes #:nodoc:
    
    class Name
      attr_reader :id, :name
      def initialize(elem) #:nodoc:
        @id = elem['id'].to_i
        @id = elem['name']        
      end
    end
    
    # Represents an Alliance as it appears in the Reve::API#alliances call.
    # Attributes
    # * name ( String ) - Full Name of the Alliance
    # * short_name ( String ) - Short name (ticker) of the Alliance
    # * id ( Fixnum ) - The Alliance's Eve-Online ID
    # * executor_corp_id ( Fixnum ) - ID of the Corporation that's in charge of the Alliance
    # * member_count ( Fixnum ) - The number of members that are in the Alliance
    # * start_date ( Time ) - When the Alliance was formed.
    # * member_corporations ( [Corporation] ) - Array of the Corporation objects that belong to the Alliance.
    class Alliance
      attr_reader :name, :short_name, :id, :executor_corp_id, :member_count, :start_date
      attr_accessor :member_corporations
      def initialize(elem) #:nodoc:
        @name             = elem['name']
        @short_name       = elem['shortName']
        @id               = elem['allianceID'].to_i
        @executor_corp_id = elem['executorCorpID'].to_i
        @member_count     = elem['memberCount'].to_i
        @start_date       = elem['startDate'].to_time
        @member_corporations = []
      end
    end

    # Only for use in Alliance class (member_corporations array) from the Reve::API#alliances call
    # Attributes
    # * id ( Fixnum ) - ID of the Corporation (use this in the Reve::API#corporation_sheet call)
    # * start_date ( Time ) - When the Corporation was started?
    class Corporation
      attr_reader :id, :start_date
      def initialize(elem) #:nodoc:
        @id = elem['corporationID'].to_i
        @start_date = elem['startDate'].to_time
      end      
    end
    
    class EveFactionWarStat
      attr_accessor :faction_participants, :faction_wars
      attr_reader :kills_yesterday, :kills_last_week, :kills_total,
                  :victory_points_yesterday, :victory_points_last_week,
                  :victory_points_total
      def initialize(elem,wars,participants) #:nodoc:
        @faction_wars = wars
        @faction_participants = participants
        @kills_yesterday = elem['killsYesterday'].to_i
        @kills_last_week = elem['killsLastWeek'].to_i
        @kills_total = elem['killsTotal'].to_i
        @victory_points_yesterday = elem['victoryPointsYesterday'].to_i
        @victory_points_last_week = elem['victoryPointsLastWeek'].to_i
        @victory_points_total = elem['victoryPointsTotal'].to_i
      end
    end
    
    # Maps a participant in a FactionWar. Can be a:
    # * PersonalFactionWarParticpant
    # * CorporateFactionWarParticpant
    # * FactionwideFactionWarParticpant
    # Attributes:
    # * faction_id ( Fixnum ) - ID of the Faction to which the participant belongs
    # * faction_name ( String ) - Name of the Faction
    # * kills_yesterday ( Fixnum )
    # * kills_last_week ( Fixnum )
    # * kills_total ( Fixnum )
    # * victory_points_yesterday ( Fixnum )
    # * victory_points_last_week ( Fixnum )
    # * victory_points_total ( Fixnum )
    class FactionWarParticpant
      attr_reader :faction_id, :faction_name, :enlisted_at, :kills_yesterday, 
                  :kills_last_week, :kills_total, :victory_points_yesterday, 
                  :victory_points_last_week, :victory_points_total
      def initialize(elem) #:nodoc:
        @faction_id = elem['factionID'].to_i
        @faction_name = elem['factionName']
        @kills_yesterday = elem['killsYesterday'].to_i
        @kills_last_week = elem['killsLastWeek'].to_i
        @kills_total = elem['killsTotal'].to_i
        @victory_points_yesterday = elem['victoryPointsYesterday'].to_i
        @victory_points_last_week = elem['victoryPointsLastWeek'].to_i
        @victory_points_total = elem['victoryPointsTotal'].to_i
      end
    end
    
    # Represents a Character's stats as a FactionWarParticpant.
    # Attributes:
    # * (See FactionWarParticpant for more)
    # * current_rank ( Fixnum ) - Current Rank
    # * highest_rank ( Fixnum ) - Highest Rank
    # * enlisted_at ( Time ) - When the participant enlisted into the Faction
    class PersonalFactionWarParticpant < FactionWarParticpant
      attr_reader :current_rank, :highest_rank
      def initialize(elem) #:nodoc:
        super(elem)
        @current_rank = elem['currentRank'].to_i
        @highest_rank = elem['highestRank'].to_i
        @enlisted_at = elem['enlisted'].to_time
      end
    end
    
    # Represents a Corpration's stats as a FactionWarParticpant.
    # Attributes:
    # * (See FactionWarParticpant for more)
    # * pilots ( Fixnum ) - Number of pilots (Characters) in the Corporation
    # * enlisted_at ( Time ) - When the participant enlisted into the Faction
    class CorporateFactionWarParticpant < FactionWarParticpant
      attr_reader :pilots
      def initialize(elem) #:nodoc:
        super(elem)
        @pilots = elem['pilots'].to_i
        @enlisted_at = elem['enlisted'].to_time
      end
    end
    
    # Represents an entire Faction's stats as a FactionWarParticpant.
    # Attributes:
    # * (See FactionWarParticpant for more)
    # * pilots ( Fixnum ) - Number of pilots (Characters) in the Corporation
    class FactionwideFactionWarParticpant < FactionWarParticpant
      attr_reader :pilots, :systems_controlled
      def initialize(elem) #:nodoc:
        super(elem)
        @pilots = elem['pilots'].to_i
        @systems_controlled = elem['systemsControlled'].to_i
      end
    end
    
    # Represents a single FactionWar between two Factions (e.g., Gallente v. Caldari)
    # Attributes:
    # * faction_id ( Fixnum ) - ID of the belligerant Faction
    # * faction_name ( String ) - Name of the belligerant Faction.
    # * against_id ( Fixnum ) - ID of the Faction that this war is against.
    # * against_name ( String ) - Name of the Faction that this war is against.
    class FactionWar
      attr_reader :faction_id, :faction_name, :against_id, :against_name
      def initialize(elem) #:nodoc:
        @faction_id = elem['factionID'].to_i
        @faction_name = elem['factionName']
        @against_id = elem['againstID'].to_i
        @against_name = elem['againstName']
      end      
    end
    
    # The status of a System with regards to a FactionWar. Who controls what 
    # and what System is contested
    # Attributes:
    # * system_id ( Fixnum ) - ID of the System
    # * system_name ( String ) - Name of the System
    # * faction_id ( Fixnum | NilClass ) - ID of the Faction that is occupying this System. If no Faction controls this System this will be nil.
    # * faction_name ( String | NilClass ) - Name of the Faction that is occupying this System. If no Faction controls this System this will be nil.
    # * contested ( Boolean ) - Is this System contested?
    class FactionWarSystemStatus
      attr_reader :system_id, :system_name, :faction_id, :faction_name, :contested
      def initialize(elem) #:nodoc:
        @system_id = elem['solarSystemID'].to_i
        @system_name = elem['solarSystemName']
        @faction_id = elem['occupyingFactionID'].to_i
        @faction_name = elem['occupyingFactionName']
        @contested = elem['contested'] == 'True'
        if @faction_id == 0
          @faction_id = nil
          @faction_name = nil
        end
      end
    end
    
    class FactionWarKills
      attr_reader :kills
      def initialize(elem) #:nodoc:
        @kills = elem['kills'].to_i
      end
    end
    
    class CharacterFactionKills < FactionWarKills
      attr_reader :name, :id
      def initialize(elem) #:nodoc:
        super(elem)
        @name = elem['characterName']
        @id = elem['characterID'].to_i
      end
    end
    class CorporationFactionKills < FactionWarKills
      attr_reader :name, :id
      def initialize(elem) #:nodoc:
        super(elem)
        @name = elem['corporationName']
        @id = elem['corporationID'].to_i
      end
    end
    class FactionKills < FactionWarKills
      attr_reader :name, :id
      def initialize(elem) #:nodoc:
        super(elem)
        @name = elem['factionName']
        @id = elem['factionID'].to_i
      end
    end  
    
    class FactionWarVictoryPoints
      attr_reader :victory_points
      def initialize(elem) #:nodoc:
        @victory_points = elem['victoryPoints'].to_i
      end
    end
    class CharacterFactionVictoryPoints < FactionWarVictoryPoints
      attr_reader :name, :id
      def initialize(elem) #:nodoc:
        super(elem)
        @name = elem['characterName']
        @id = elem['characterID'].to_i
      end
    end
    class CorporationFactionVictoryPoints < FactionWarVictoryPoints
      attr_reader :name, :id
      def initialize(elem) #:nodoc:
        super(elem)
        @name = elem['corporationName']
        @id = elem['corporationID'].to_i
      end
    end
    class FactionVictoryPoints < FactionWarVictoryPoints
      attr_reader :name, :id
      def initialize(elem) #:nodoc:
        super(elem)
        @name = elem['factionName']
        @id = elem['factionID'].to_i
      end
    end
    
    # Faction War Top Stats. This is different than the rest of the classes.
    # Each attribute on this class is a Hash with the following keys:
    # * yesterday_kills ( Array )
    # * yesterday_victory_points ( Array )
    # * last_week_kills ( Array )
    # * last_week_victory_points ( Array )
    # * total_kills ( Array )
    # * total_victory_points ( Array )
    # The value of each key is an Array whose class is specified below (under 'Attributes' list) for each Attribute.
    # Attributes:
    # * characters ( Hash ) - CharacterFactionVictoryPoints, CharacterFactionKills
    # * corporations ( Hash ) - CorporationFactionVictoryPoints, CorporationFactionKills
    # * factions ( Hash ) - FactionVictoryPoints, FactionWarKills
    # Access: Reve::API#faction_war_top_stats.characters[:yesterday_kills] => array of CharacterFactionKills objects.
    class FactionWarTopStats
      attr_reader :characters, :corporations, :factions
      def initialize(characters, corporations, factions) #:nodoc:
        @characters = characters
        @corporations = corporations
        @factions = factions        
      end
      
    end
    
    # A Skill has a RequiredAttribute, either a PrimaryAttribute or SecondaryAttribute, which both derrive from this.
    # Attributes
    # * name ( String ) - Name of the required Attribute
    # See Also: PrimaryAttribute, SecondaryAttribute, Skill, Reve::API#skill_tree
    class RequiredAttribute
      attr_reader :name
      def initialize(attrib) #:nodoc:
        @name = attrib
      end
    end
    # Denotes the PrimaryAttribute of the RequiredAttribute pair for a Skill. See also
    # SecondaryAttribute and RequiredAttribute
    class PrimaryAttribute < RequiredAttribute
    end
    # Denotes the SecondaryAttribute of the RequiredAttribute pair for a Skill. See also
    # PrimaryAttribute and RequiredAttribute
    class SecondaryAttribute < RequiredAttribute
    end
    
    # Represents the victim of a Kill.
    # Attributes:
    # * id ( Fixnum ) - ID of the Character that was killed.
    # * name ( String ) - The name of the Character that was killed.
    # * corporation_id ( Fixnum ) - The ID of the Corporation that the victim belongs to.
    # * corporation_name ( String ) - Name of the Corporation that the victim belongs to.
    # * alliance_id ( Fixnum | NilClass ) - The ID of the Alliance that the victim belongs to, if applicable. Will be nil unless the victim was in an Alliance
    # * damage_taken ( Fixnum ) - The amount of damage the victim took before being killed.
    # * ship_type_id ( Fixnum ) - ID of the ship type (references CCP data dump) that the victim was flying.
    # See Also: KillAttacker, Kill, KillLoss, Reve::API#personal_kills, Reve::API#corporate_kills
    class KillVictim
      attr_reader :id, :name, :corporation_id, :corporation_name, :alliance_id, :damage_taken, :ship_type_id
      def initialize(elem) #:nodoc:
        @id = elem['characterID'].to_i
        @name = elem['characterName']
        @corporation_id = elem['corporationID']
        @corporation_name = elem['corporationName']
        @alliance_id = elem['allianceID'] == "0" ? nil : elem['allianceID'].to_i
        @damage_taken = elem['damageTaken'].to_i
        @ship_type_id = elem['shipTypeID'].to_i
      end
    end
    
    # It's possible to be killed/attacked by an NPC. In this case character_id, character_name, 
    # alliance_id, alliance_name and weapon_type_id will be nil
    # Represents an attacker (attacking a KillVictim) in a Kill
    # Attributes
    # * id ( Fixnum | NilClass ) - ID of the attacker; nil if the attacker was an NPC or not a Character
    # * name ( String | NilClass ) - Name of the attacker; nil if the attacker was an NPC or not a Character
    # * corporation_id ( Fixnum ) - ID of the Corporation that the Character belongs to (could be NPC Corporation!)
    # * corporation_name ( String ) - Name of the Corporation that the Character belongs to (could be NPC Corporation!)
    # * alliance_id ( Fixnum | NilClass ) - ID of the Alliance that the Character belongs to (nil if the KillAttacker doesn't belong to an Alliance)
    # * security_status ( Float ) - Security status of the KillAttacker
    # * damage_done ( Fixnum ) - How much damage the KillAttacker did.
    # * final_blow ( Boolean ) - True if this KillAttacker got the final blow to kill the KillVictim
    # * weapon_type_id ( Fixnum | NilClass ) - Type ID of the (a?) weapon the KillAttacker was firing. (Refer to CCP database dump invtypes)
    # * ship_type_id ( Fixnum ) - Type ID of the ship the KillAttacker was flying. (Refer to CCP database dump invtypes)
    # See Also: Kill, KillLoss, KillVictim, Reve::API#personal_kills, Reve::API#corporate_kills
    class KillAttacker
      attr_reader :id, :name, :corporation_id, :corporation_name, :alliance_id, :alliance_name,
                  :security_status, :damage_done, :final_blow, :weapon_type_id, :ship_type_id
      def initialize(elem) #:nodoc:
        @id = elem['characterID'] == "0" ? nil : elem['characterID'].to_i
        @name = elem['characterName'].empty? ? nil : elem['characterName']
        @corporation_id = elem['corporationID'].to_i
        @corporation_name = elem['corporationName']
        @alliance_id = elem['allianceID'] == "0" ? nil : elem['allianceID'].to_i
        @alliance_name = elem['allianceName'].empty? ? nil : elem['allianceName']
        @security_status = elem['securityStatus'].to_f
        @damage_done = elem['damageDone'].to_i
        @final_blow = elem['finalBlow'] == "1"
        @weapon_type_id = elem['weaponTypeID'] == "0" ? nil : elem['weaponTypeID'].to_i
        @ship_type_id = elem['shipTypeID'].to_i
      end
    end
    
    # A model to represent losses from being killed.
    # Attributes
    # * type_id ( Fixnum ) - Type ID of the KillLoss. (Refer to CCP database dump invtypes)
    # * flag ( Fixnum ) - A flag to denoe some special qualities of the KillLoss such as where it was mounted or if it was in a container. Refer to http://wiki.eve-dev.net/API_Inventory_Flags
    # * quantity_dropped ( Fixnum ) - The number of +type_id+ that were dropped for looting - e.g., not destroyed.
    # * quantity_destroyed ( Fixnum ) - The number of +type_id+ that were destroyed in the Kill.
    # * contained_losses ( [KillLoss] ) - If the KillLoss was a container (refer to +type_id+) then this array will be populated with a list of KillLoss objects that were inside the container.
    # See Also: Kill, KillAttacker, KillVictim, Reve::API#personal_kills, Reve::API#corporate_kills
    class KillLoss
      attr_reader :type_id, :flag, :quantity_dropped, :quantity_destroyed
      attr_accessor :contained_losses
      def initialize(elem)
        @type_id = elem['typeID'].to_i
        @flag = elem['flag'].to_i
        @quantity_dropped = elem['qtyDropped'].to_i
        @quantity_destroyed = elem['qtyDestroyed'].to_i
        @contained_losses = []        
      end
    end
    
    
    # Simple class to contain the information relevant to a single Kill.
    # Comprised of an array of KillLoss, an array of KillAttacker and one KillVictim
    # Attributes
    # * victim ( KillVictim ) - Instance of the KillVictim class to represent the victim of the Kill.
    # * attackers ( [KillAttacker] ) - Array of KillAttacker objects that represent the people who killed the +victim+.
    # * losses ( [KillLoss] ) - Array of KillLoss objects that represents the +victim+'s items destroyed in the Kill.
    # * system_id ( Fixnum ) - The ID of the System that the Kill took place in.
    # * id ( Fixnum ) - The ID of this specific Kill
    # * moon_id ( Fixnum | NilClass ) - The ID of the Moon that this kill happened at (due to a POS?), if any; nil otherwise.
    # See Also: KillAttacker, KillVictim, KillLoss, Reve::API#personal_kills, Reve::API#corporate_kills
    class Kill
      attr_reader :victim, :attackers, :losses
      attr_reader :system_id, :created_at, :id, :moon_id
      def initialize(elem, victim, attackers, losses) #:nodoc:
        @victim, @attackers, @losses = victim, attackers, losses
        @system_id = elem['solarSystemID'].to_i
        @created_at = elem['killTime'].to_time
        @id = elem['killID'].to_i
        @moon_id = elem['moonID'] == "0" ? nil : elem['moonID'].to_i
      end
    end
    
    
    # A container or singleton (unpackaged thing).
    # Attributes
    # * item_id ( Fixnum ) - A CCP-specific ID for the Asset/AssetContainer
    # * location_id ( Fixnum ) - The ID of the Station (or POS?) that the Asset/AssetContainer is at.
    # * type_id ( Fixnum ) - Type ID of the Asset/AssetContainer. (Refer to CCP database dump invtypes)
    # * quantity ( Fixnum ) - The number of Asset/AssetContainer at this +location_id+
    # * flag ( Fixnum ) - Inventory flag, refer to http://wiki.eve-dev.net/API_Inventory_Flags (See also KillLoss's flag)
    # * singleton ( Boolean ) - True if the Asset/AssetContainer is not packaged up.
    # * assets ( [Asset] ) - A list of Asset objects that are contained in this AssetContainer.
    # See Also: Asset, Reve::API#corporate_assets_list, Reve::API#personal_assets_list
    class AssetContainer
      attr_reader :item_id, :location_id, :type_id, :quantity, :flag, :singleton
      attr_accessor :assets
      def initialize(elem)
        @item_id = elem['itemID'].to_i
        @location_id = elem['locationID'].to_i
        @type_id = elem['typeID'].to_i
        @quantity = elem['quantity'].to_i
        @flag = elem['flag'].to_i
        @singleton = elem['singleton'] == "1"
        @assets = []
      end
    end
    
    # An item contained within an AssetContainer (ship, or container)
    # Attributes
    # * item_id ( Fixnum ) - A CCP-specific ID for the Asset/AssetContainer
    # * type_id ( Fixnum ) - Type ID of the Asset/AssetContainer. (Refer to CCP database dump invtypes)
    # * quantity ( Fixnum ) - The number of Asset/AssetContainer at this +location_id+
    # * flag ( Fixnum ) - Inventory flag, refer to http://wiki.eve-dev.net/API_Inventory_Flags (See also KillLoss's flag)
    # See Also: AssetContainer, Reve::API#corporate_assets_list, Reve::API#personal_assets_list
    class Asset
      attr_reader :item_id, :type_id, :quantity, :flag, :singleton
      def initialize(elem) #:nodoc:
        @item_id = elem['itemID'].to_i
        @type_id = elem['typeID'].to_i
        @quantity = elem['quantity'].to_i
        @flag = elem['flag'].to_i
        @singleton = elem['singleton'].to_i
      end
    end

    # Used for attribute enhancers (in-game Implants)
    # IntelligenceEnhancer, MemoryEnhancer, PerceptionEnhancer, CharismaEnhancer
    # and WillpowerEnhancer all subclass this class as this AttributeEnhancer 
    # class is never used (except in a fault-case). Use the kind_of? method 
    # to determine what kind of AttributeEnhancer one is dealing with.
    # Attributes
    # * name ( String ) - The name of the AttributeEnhancer (implant)
    # * value ( Fixnum ) - How much the +name+ implant boosts.
    # See Also: CharacterSheet, Reve::API#character_sheet
    class AttributeEnhancer
      attr_accessor :name, :value
      def initialize(name = "", value = 0) #:nodoc:
        @name = name
        @value = value.to_i
      end
    end
    class IntelligenceEnhancer < AttributeEnhancer; end
    class MemoryEnhancer < AttributeEnhancer; end
    class PerceptionEnhancer < AttributeEnhancer; end
    class CharismaEnhancer < AttributeEnhancer; end
    class WillpowerEnhancer < AttributeEnhancer; end
    
    
    # Certificate tree container. This looks like:
    # [CertificateCategory]
    #   [CertificateClass]
    #     [Certificate]
    #       [CertificateRequiredSkill]
    #       [CertificateRequiredCertificate]
    class CertificateTree
      attr_accessor :categories
      def initialize(categories = []) #:nodoc:
        @categories = categories
      end
    end
    
    # Category of Certificates.
    # Attributes:
    # * id ( Fixnum ) - ID of the CertificateCategory
    # * name ( String ) - Name of the CertificateCategory
    # * classes ( [ CertificateClass ] ) - Array of CertificateClass objects under this Category
    class CertificateCategory
      attr_reader :name, :id
      attr_accessor :classes
      def initialize(elem) #:nodoc:
        @name = elem['categoryName']
        @id = elem['categoryID'].to_i
        @classes = []
      end
    end
    
    # A class of Certificates.
    # Attributes:
    # * id ( Fixnum ) - ID of the CertificateClass
    # * name ( String ) - Name of the CertificateClass
    # * classes ( [ Certificate ] ) - Array of Certificate objects under this class
    class CertificateClass
      attr_reader :name, :id
      attr_accessor :certificates
      def initialize(elem) #:nodoc:
        @name = elem['className']
        @id = elem['classID'].to_i
        @certificates = []
      end
    end
    class Certificate
      attr_reader :id, :grade, :corporation_id, :description
      attr_accessor :required_skills, :required_certificates
      def initialize(elem)
        @id = elem['certificateID'].to_i
        @grade = elem['grade'].to_i
        @corporation_id = elem['corporationID'].to_i
        @description = elem['description']
        @required_certificates = []
        @required_skills = []
      end
    end
    class CertificateRequiredSkill
      attr_reader :id, :level
      def initialize(elem)
        @id = elem["typeID"].to_i
        @level = elem["level"].to_i
      end
    end
    
    class CertificateRequiredCertificate
      attr_reader :id, :grade
      def initialize(elem)
        @id = elem["certificateID"].to_i
        @grade = elem["grade"].to_i
      end
    end

    # Represents a Character for the Reve::API#characters, Reve::API#character_name and Reve::API#character_id calls.
    # Attributes
    # * name ( String ) - Name of the Character
    # * id ( Fixnum ) - ID of the Character (use this for Reve::API method calls)
    # * corporation_name ( String | NilClass ) - Name of the Corporation the Character belongs to. Nil if being used for Reve::API#character_name or Reve::API#character_id
    # * corporation_id ( Fixnum | NilClass ) - ID of the Corporation the Character belongs to. Nil if being used for Reve::API#character_name or Reve::API#character_id
    # See Also: Reve::API
    class Character
      attr_reader :name, :id, :corporation_name, :corporation_id
      def initialize(elem) #:nodoc:
        @id               = elem['characterID'].to_i
        @name             = elem['name']
        @corporation_name = elem['corporationName']
        @corporation_id   = elem['corporationID'].to_i
      end
    end
  

    # Holds the result of the Reve::API#character_sheet call.
    # This has all of the stuff that appears in the in-game 'character sheet'
    # screen.
    # The skills array is a Skill list (no name is stored in it)
    # The enhancers array is an AttributeEnhancer derrived list
    # Attributes
    # * name ( String ) - Name of the Character
    # * race ( String ) - Race of the Character
    # * gender ( String ) - Gender of the Character
    # * id ( Fixnum ) - ID of the Character
    # * corporation_name ( String ) - Name of the Corporation the Character is in
    # * corporation_id ( Fixnum ) - ID of the Corporation the Character is in
    # * balance ( Float ) - How much ISK the Character has
    # * intelligence ( Fixnum ) - Character's Intelligence level
    # * memory ( Fixnum ) - 
    # * charisma ( Fixnum ) - 
    # * perception ( Fixnum ) - 
    # * willpower ( Fixnum ) - 
    # * skills ( [Skill] ) - An Array of Skill objects that the Character has trained.
    # * enhancers ( [AttributeEnhancer] ) - An Array of any implants (AttributeEnhancer) the Character has in its head.
    # See Also: Reve::API#character_sheet, AttributeEnhancer (and subclasses), Skill
    class CharacterSheet
      attr_accessor :name, :race, :bloodline, :gender, :id, :corporation_name, :corporation_id, :balance
      attr_accessor :intelligence, :memory, :charisma, :perception, :willpower, :clone_name, :clone_skill_points
      attr_accessor :skills, :enhancers, :roles, :certificate_ids, :corporate_titles
      attr_accessor :corporationRolesAtHQ, :corporationRoles, :corporationRolesAtBase, :corporationRolesAtOther
      alias_method :corporate_roles_at_hq,    :corporationRolesAtHQ
      alias_method :corporate_roles,          :corporationRoles
      alias_method :corporate_roles_at_base,  :corporationRolesAtBase
      alias_method :corporate_roles_at_other, :corporationRolesAtOther
      def initialize #:nodoc:
        @skills = []
        @enhancers = []
        @roles = []
        @certificate_ids = []
        @corporate_titles = []
        @corporationRolesAtHQ = []
        @corporationRoles = []
        @corporationRolesAtBase = []
        @corporationRolesAtOther = []
      end
      def clonename=(n) #:nodoc:
        @clone_name = n
      end
      def cloneskillpoints=(i) #:nodoc:
        @clone_skill_points = i
      end
      def characterid=(i) #:nodoc:
        @id = i.to_i
      end
      def corporationname=(i) #:nodoc:
        @corporation_name = i
      end
      def corporationid=(i) #:nodoc:
        @corporation_id = i.to_i
      end
    end
    
    # Holds the result of the Reve::API#conqurable_stations call.
    # Attributes
    # * id ( Fixnum ) - ID of the ConqurableStation
    # * name ( String ) - Name of the ConqurableStation
    # * type_id ( Fixnum ) - What kind of ConqurableStation Station it is (Refer to CCP database dump invtypes).
    # * type_name ( String ) - Name of the kind of Station this ConqurableStation is. (May not be present??)
    # * corporation_id ( Fixnum ) - ID of the Corporation that owns the ConqurableStation
    # * corporation_name ( String ) - Name of the Corporation that owns the ConqurableStation.
    # See Also: Sovereignty, Reve::API#conqurable_stations, Reve::API#sovereignty, Reve::API#corporation_sheet, CorporationSheet
    class ConqurableStation
      attr_reader :id, :name, :type_id, :type_name, :system_id, :system_name, :corporation_id, :corporation_name
      def initialize(elem) #:nodoc:
        @id = elem['stationID'].to_i
        @name = elem['stationName']
        @type_id = elem['stationTypeID'].to_i
        @type_name = elem['stationTypeName']
        @corporation_id = elem['corporationID'].to_i
        @corporation_name = elem['corporationName']
      end
    end
    class ConquerableStation < ConqurableStation; end
    
    # Part of the CorporationSheet; represnets a Corporation's in-game logo
    # All of these values are internal to CCP; +shape_1+ matches with +color_1+ and so on.
    # Attributes
    # * graphic_id ( Fixnum ) 
    # * shape_1 ( Fixnum ) 
    # * shape_2 ( Fixnum )
    # * shape_3 ( Fixnum )
    # * color_1 ( Fixnum )
    # * color_2 ( Fixnum )
    # * color_3 ( Fixnum )
    class CorporateLogo
      attr_reader :graphic_id, :shape_1, :shape_2, :shape_3, :color_1, :color_2, :color_3
      def initialize(elem) #:nodoc:
        @graphic_id = elem['graphicID'].to_i
        @shape_1    = elem['shape1'].to_i
        @shape_2    = elem['shape2'].to_i
        @shape_3    = elem['shape3'].to_i
        @color_1    = elem['color1'].to_i
        @color_2    = elem['color2'].to_i
        @color_3    = elem['color3'].to_i                
      end      
    end
    
    
    # Part of the CharacterSheet; represents a grantable Corporation role to a
    # Character.
    # Attributes:
    # * id ( Fixnum ) - Bitmask/ID of the role
    # * name ( String ) - Name of the role
    class CorporateRole
      attr_reader :id, :name
      def initialize(elem) #:nodoc:
        @id = elem['roleID'].to_i
        @name = elem['roleName']
      end
    end
    
    # Part of the CharacterSheet; represents a grantable Corporation title to a
    # Character.
    # Attributes:
    # * id ( Fixnum ) - Bitmask/ID of the title
    # * name ( String ) - Name of the title
    class CorporateTitle
      attr_reader :id, :name
      def initialize(elem) #:nodoc:
        @id = elem['titleID'].to_i
        @name = elem['titleName']
      end
    end
    
    # Part of the CorporationSheet. Describes a division in the wallet
    # Attributes
    # * key ( Fixnum ) - Account key. Used for things like WalletBalance and such.
    # * description ( String ) - Description of the WalletDivision
    # See Also CorporationSheet
    class WalletDivision
      attr_reader :key, :description
      def initialize(elem) #:nodoc:
        @key = elem['accountKey'].to_i
        @description = elem['description'].split(/\n/).collect { |s| s.strip }.join(' ') # newlines to spaces
      end
    end
    
    # Part of the CorporationSheet. Describes a division of the Corporation
    # Attributes
    # * key ( Fixnum ) - Account key.
    # * description ( String ) - Description of the CorporateDivision
    # See Also CorporationSheet
    class CorporateDivision
      attr_reader :key, :description
      def initialize(elem) #:nodoc:
        @key = elem['accountKey'].to_i
        @description = elem['description'].split(/\n/).collect { |s| s.strip }.join(' ') # newlines to spaces
      end
    end
    
    # Describes a Corporation. The public listing when a Corporation is in an Alliance is limited. When the requestor is in the Corporation for which the CorporationSheet is for then the details are full.
    # Attributes
    # * id ( Fixnum ) - ID of the Corporation
    # * name ( String ) - Name of the Corporation
    # * ticker ( String ) - Ticker (short name) of the Corporation
    # * ceo_id ( Fixnum ) - The ID of the Character who is the CEO of the Corporation
    # * ceo_name ( String ) - The name of the Character whois he CEO of the Corporation
    # * station_id ( Fixnum ) - The ID of the Corporation's home Station
    # * station_name ( Station ) - The name of the Corporation's home Station
    # * description ( String ) - Corporation's description
    # * url ( String ) - URL of the Corporation's website. If none is set the value is an empty String
    # * alliance_id ( Fixnum | NilClass ) - ID of the Alliance that this Corporation belongs to; nil if no membership
    # * alliance_name ( String | NilClass ) - Name of the Alliance that this Corporation belongs to; nil if no membership
    # * tax_rate ( Float ) - Tax rate for the Corporation
    # * member_count ( Fixnum ) - How many Characters are in the Corporation
    # * member_limit ( Fixnum ) - Member limit (Max number of Characters allowed in?)
    # * shares ( Fixnum ) - Number of shares available for the Corporation
    # * divisions ( [CorporateDivision] ) - Array of CorporateDivision objects representing the differet divisions in the Corporation
    # * wallet_divisions ( [WalletDivision] ) - Array of WalletDivision objects representing the different divisions in the wallet for the Corporation
    # * logo ( CorporateLogo ) - An object to represent the Corporation's logo.
    # See Also: CorporateLogo, WalletDivision, CorporateDivision, Corporation, Reve::API#corporation_sheet
    class CorporationSheet
      attr_reader   :id, :name, :ticker, :ceo_id, :ceo_name, :station_id, :station_name, :description, :url,
                    :alliance_id, :alliance_name, :tax_rate, :member_count, :member_limit, :shares
      attr_accessor :divisions, :wallet_divisions, :logo
      
      # Call it +h+ here cos it's a Hash and not any Hpricot object like in other constructors
      def initialize(h, divisions = [],wallet_divisions = [], logo =Reve::Classes::CorporateLogo.new(Hash.new(0)) ) #:nodoc:
        @divisions = divisions
        @wallet_divisions = wallet_divisions
        @logo = logo
        @id = h[:id].to_i
        @name = h[:name]
        @ticker = h[:ticker]
        @ceo_id = h[:ceo_id].to_i
        @ceo_name = h[:ceo_name]
        @station_id = h[:station_id].to_i
        @station_name = h[:station_name]
        @description = h[:description].split(/\n/).collect { |s| s.strip }.join(' ') # newlines to spaces
        @url = h[:url] || ""
        @alliance_id = h[:alliance_id].to_i rescue nil
        @alliance_name = h[:alliance_name] rescue nil
        @tax_rate = h[:tax_rate].to_f
        @member_count = h[:member_count].to_i
        @member_limit = h[:member_limit].to_i
        @shares = h[:shares].to_i
      end                              
    end
    
    # This is just for getting the list and writing to test/xml/errors
    class APIError #:nodoc:
      attr_reader :code, :text
      def initialize(elem)
        @code = elem['errorCode'].to_i
        @text = elem['errorText']
      end
    end
    
    
    # Container for the CharacterMedal since there's two kinds returned in XML
    # Attributes:
    # * current_corporation ( [ CharacterMedal ] ) - Array of CharacterMedal for the Corporation this Character is currently in
    # * other_corporation ( [ CharacterOtherCorporateMedal ] ) - Array of CharacterOtherCorporateMedal from other Corporations
    # See also: Medal, CharacterMedal, Reve::API#character_medals
    class CharacterMedals
      attr_reader :current_corporation, :other_corporation
      def initialize(current, other)
        @current_corporation = current
        @other_corporation = other
      end      
    end
    
    # Parent class for Medals
    # Attributes:
    # * id ( Fixnum ) - ID for the Medal
    # * issued_at ( Time ) - When the Medal was issued (Note: Not valid/present on the CorporateMedal)
    # See Also: CharacterMedal, CharacterOtherCorporateMedal, CorporateMemberMedal, CorporateMedal
    class Medal
      attr_reader :id, :issued_at
      def initialize(elem) #:nodoc:
        @id = elem["medalID"].to_i
        @issued_at = elem["issued"].to_time
      end
    end
    
    # Composed in CharacterMedals. Issued by the Corporation the Character is a member
    # Attributes:
    # * reason ( String ) - Why the CharacterMedal was issued
    # * issuer_id ( Fixnum ) - Who issued the CharacterMedal
    # * status ( String ) - public or private (presumably), if this CharacterMedal is public or private.
    # See Also: Medal, CharacterOtherCorporateMedal, CorporateMemberMedal, CorporateMedal
    class CharacterMedal < Medal
      attr_reader :reason, :issuer_id, :status
      def initialize(elem) #:nodoc:
        super(elem)
        @reason = elem["reason"]
        @issuer_id = elem["issuerID"].to_i
        @status = elem["status"]
      end
      # If the CharacterMedal is public
      def is_public?
        @status == "public"
      end
      # If the CharacterMedal is private (not public)
      def is_private?
        ! is_public?
      end
    end
    
    # Composed in CharacterMedals. Issued by the Corporation the Character is a member
    # Attributes:
    # * corporation_id ( Fixnum ) - ID of the Corporation that issued the CharacterOtherCorporateMedal
    # * title ( String ) - The title this CharacterOtherCorporateMedal bestows on the Character
    # * description ( String ) - Description of the CharacterOtherCorporateMedal.
    # See Also: Medal, CharacterMedal, CorporateMemberMedal, CorporateMedal
    class CharacterOtherCorporateMedal < CharacterMedal
      attr_reader :corporation_id, :title, :description
      def initialize(elem) #:nodoc:
        super(elem)
        @corporation_id = elem["corporationID"].to_i
        @title = elem["title"]
        @description = elem["description"]
      end      
    end
    
    # All of the Medals that the members of a Corporation have.
    # Attributes:
    # * character_id ( Fixnum ) - ID of the Character that has this CorporateMemberMedal
    # * reason ( String ) - Why the CorporateMemberMedal is bestowed
    # * issuer_id ( Fixnum ) - Who issued the CorporateMemberMedal
    # * status ( String ) - public or private (presumably), if this CorporateMemberMedal is public or private.
    # See Also: Medal, CharacterMedal, CharacterOtherCorporateMedal, CorporateMedal
    class CorporateMemberMedal < Medal
      attr_reader :character_id, :reason, :issuer_id, :status
      def initialize(elem) #:nodoc:
        super(elem)
        @character_id = elem["characterID"].to_i
        @reason = elem["reason"]
        @issuer_id = elem["issuerID"].to_i
        @status = elem["status"]
      end
      # If the CharacterMedal is public
      def is_public?
        @status == "public"
      end
      # If the CorporateMemberMedal is private (not public)
      def is_private?
        ! is_public?
      end
    end
    
    # The medals a Corporation can give out.
    # Attributes
    # * title ( String ) - Title that this CorporateMedal gives
    # * creator_id ( Fixnum ) - Who created the CorporateMedal
    # * description ( String ) Description of the CorporateMedal
    # * created_at ( Time ) - When the CorporateMedal was created.
    # See Also: Medal, CharacterMedal, CharacterOtherCorporateMedal, CorporateMemberMedal, 
    class CorporateMedal < Medal
      attr_reader :title, :creator_id, :description, :created_at
      def initialize(elem) #:nodoc:
        super(elem)
        @title = elem["title"]
        @creator_id = elem["creatorID"].to_i
        @description = elem["description"]
        @created_at = elem["created"].to_time
      end
    end
    
    # Used for the Reve::API#map_jumps method. If there are no jumps it is not listed.
    # Attributes
    # * system_id ( Fixnum ) - ID of the System
    # * jumps ( Fixnum ) - Number of jumps through the System
    # See Also: MapKill, Reve::API#map_jumps
    class MapJump
      attr_reader :system_id, :jumps
      def initialize(elem) #:nodoc:
        @system_id = elem['solarSystemID'].to_i
        @jumps     = elem['shipJumps'].to_i
      end
    end
    
    # Used for the Reve::API#personal_market_orders and Reve::API#corporate_market_orders
    # Each of those derrive from this parent class.
    # Attributes
    # * id ( Fixnum ) - ID of the MarketOrder. This is a CCP internal ID and is not guaranteed to always be unique! You may want to generate your own globally unique ID for this.
    # * character_id ( Fixnum ) - ID of the Character who set this MarketOrder up
    # * station_id ( Fixnum ) - ID of the Station where the MarketOrder is
    # * volume_entered ( Fixnum ) - How many of +type_id+ was initially entered in the MarketOrder
    # * volume_remaining ( Fixnum ) - How many of +type_id+ is left in the MarketOrder
    # * minimum_volume ( Fixnum ) - How much of +type_id+ can be transacted (as a minimum) at once
    # * order_state ( String ) - String representation of the MarketOrder's current state. Options are: Active, Closed, Expired, Cancelled, Pending, Character Deleted
    # * type_id ( Fixnum ) - Type ID of item for which the MarketOrder was created. (Refer to CCP database dump invtypes)
    # * range ( Fixnum ) - Range of the MarketOrder. For sell orders it is always 32767 (Entire Region), for sell orders the values are -1 (Station only), 0 (Solar system), 1..40 (Number of jumps away from the Station), 32767 (Region wide)
    # * account_key ( Fixnum ) - For a CorporateMarketOrder the account key (see WalletDivision and CorporationSheet) that was used as the source/destination.
    # * duration ( Fixnum ) - Duration of the MarketOrder in days from when it was +created_at+
    # * escrow ( Float ) - How much ISK is held in escrow for the MarketOrder
    # * price ( Float ) - Unit price of the item in the MarketOrder
    # * bid ( Boolean ) - True if this MarketOrder is a sell order, false otherwise
    # * created_at ( Time ) - When the MarketOrder was created
    # See Also: CorporationSheet, WalletDivision, CorporateDivision, Reve::API#personal_market_orders, Reve::API#corporate_market_orders
    class MarketOrder
      attr_reader :id, :character_id, :station_id, :volume_entered, :volume_remaining, :minimum_volume,
                  :order_state, :type_id, :range, :account_key, :duration, :escrow, :price, :bid, :created_at
      def initialize(elem) #:nodoc:
        @id = elem['orderID'].to_i
        @character_id = elem['charID'].to_i
        @station_id = elem['stationID'].to_i
        @volume_entered = elem['volEntered'].to_i
        @volume_remaining = elem['volRemaining'].to_i
        @minimum_volume = elem['minVolume'].to_i
        @order_state = case elem['orderState'].to_i
                       when 0
                         'Active'
                       when 1
                         'Closed'
                       when 2
                         'Expired'
                       when 3
                         'Cancelled'
                       when 4
                         'Pending'
                       when 5
                         'Character Deleted'
                       end
        @type_id = elem['typeID'].to_i
        @range = elem['range'].to_i
        @account_key = elem['accountKey'].to_i
        @escrow = elem['escrow'].to_f
        @price = elem['price'].to_f
        @bid = elem['bid'] == '1'
        @duration = elem['duration'].to_i
        @created_at = elem['issued'].to_time
      end
    end
    class PersonalMarketOrder < MarketOrder; end
    class CorporateMarketOrder < MarketOrder; end
    
    
    # Used in Reve::API#personal_industry_jobs and Reve::API#corporate_industry_jobs. PersonalIndustryJob and CorporateIndustryJob
    # subclass this for more logical containment.
    # These attributes should be largely self-explanatory. There are so many of them that it's soulcrushing to document each one! (Sorry ;)
    # For further information please see: http://wiki.eve-dev.net/APIv2_Char_IndustryJobs_XML especially about +completed_status+ and +completed+
    class IndustryJob
      attr_reader :id, :assembly_line_id, :container_id, :installed_item_id, :installed_item_location_id,
                  :installed_item_quantity, :installed_item_productivity_level, :installed_item_material_level,
                  :installed_item_licensed_production_runs_remaining, :output_location_id, :installer_id, :runs,
                  :licensed_production_runs, :installed_system_id, :container_location_id, :material_multiplier,
                  :char_material_multiplier, :time_multiplier, :char_time_multiplier, :installed_item_type_id,
                  :output_type_id, :container_type_id, :installed_item_copy, :completed, :completed_successfully, 
                  :installed_item_flag, :output_flag, :activity_id, :completed_status, :installed_at, 
                  :begin_production_at, :end_production_at, :pause_production_time
      def initialize(elem) #:nodoc:
        @id = elem['jobID'].to_i; @assembly_line_id = elem['assemblyLineID'].to_i ; @container_id = elem['containerID'].to_i
        @installed_item_id = elem['installedItemID'].to_i ; @installed_item_location_id = elem['installedItemLocationID'].to_i
        @installed_item_quantity = elem['installedItemQuantity'].to_i
        @installed_item_productivity_level = elem['installedItemProductivityLevel'].to_i
        @installed_item_material_level = elem['installedItemMaterialLevel'].to_i
        @installed_item_licensed_production_runs_remaining = elem['installedItemLicensedProductionRunsRemaining'].to_i
        @output_location_id = elem['outputLocationID'].to_i ; @installer_id = elem['installerID'].to_i; @runs = elem['runs'].to_i
        @licensed_production_runs = elem['licensedProductionRuns'].to_i ; @installed_system_id = elem['installedSolarSystemID'].to_i
        @container_location_id = elem['containerLocationID'].to_i ; @material_multiplier = elem['materialMultiplier'].to_f
        @char_material_multiplier = elem['charMaterialMultiplier'].to_f; @time_multiplier = elem['timeMultiplier'].to_f
        @char_time_multiplier = elem['charTimeMultiplier'].to_f ; @installed_item_type_id = elem['installedItemTypeID'].to_i
        @output_type_id = elem['outputTypeID'].to_i ; @container_type_id = elem['containerTypeID'].to_i
        @installed_item_copy = (elem['installedItemCopy'] == "1") ; @completed = (elem['completed'] == "1")
        @completed_successfully = (elem['completedSuccessfully'] == "1")
        @installed_item_flag = elem['installedItemFlag'].to_i ; @output_flag = elem['outputFlag'].to_i
        @activity_id = elem['activityID'].to_i ; @completed_status = elem['completedStatus'].to_i
        @installed_at = elem['installTime'].to_time ; @begin_production_at = elem['beginProductionTime'].to_time
        @end_production_at = elem['endProductionTime'].to_time
        @pause_production_time = elem['pauseProductionTime'].to_time
      end
    end
    class PersonalIndustryJob < IndustryJob; end
    class CorporateIndustryJob < IndustryJob; end
      
    # Used for the Reve::API#map_kills method. If there are no kills it's not listed.
    # Attributes
    # * system_id ( Fixnum ) - ID of the System
    # * ship_kills ( Fixnum ) - Number of ships killed
    # * faction_kills ( Fixnum ) - Number of faction ships killed (NPC Pirates)
    # * pod_kills ( Fixnum ) - Number of podkills
    # See also Reve::API#map_kills, MapJump
    class MapKill
      attr_reader :system_id, :ship_kills, :faction_kills, :pod_kills
      def initialize(elem) #:nodoc:        
        @system_id     = elem['solarSystemID'].to_i
        @ship_kills    = elem['shipKills'].to_i
        @faction_kills = elem['factionKills'].to_i
        @pod_kills     = elem['podKills'].to_i
      end            
    end

    # Holds the result of the Reve::API#member_tracking call for big brother.
    # * character_id ( Fixnum ) - ID of the Character
    # * character_name ( String ) - Name of the Character
    # * start_time ( Time ) - When the Character joined the Corporation
    # * base_id ( Fixnum ) - ID of the Station (Starbase too?) where the Character calls home
    # * base ( String ) - Name of the Station (Starbase?) where the Character calls home
    # * title ( String ) - Title of the Character
    # * logon_time ( Time | NilClass ) - When the Character last logged on (or nil for non-CEOs)
    # * logoff_time ( Time | NilClass ) - When the Character last logged off (or nil for non-CEOs)
    # * location_id ( Fixnum ) - ID of the Station (Starbase too?) where the Character last/currently is
    # * location ( String ) - Name of the Station (Starbase?) where the Character last/currently is
    # * ship_type_id ( Fixnum ) - Type ID of the ship the Character is flying. (Refer to CCP database dump invtypes)
    # * ship_type ( String ) - Name of the type of ship the Character is flying
    # * roles ( String ) - List of roles for the Character
    # * grantable_roles ( String ) - List of grantable roles for the Character
    # See Also: Reve::API#member_tracking
    class MemberTracking
      attr_reader :character_id, :character_name, :start_time, :base_id, :base, :title, :logon_time, :logoff_time, 
                  :location_id, :location, :ship_type_id, :ship_type, :roles, :grantable_roles
      def initialize(elem) #:nodoc:
        @character_id    = elem['characterID'].to_i
        @character_name  = elem['name']
        @start_time      = elem['startDateTime'].to_time
        @base_id         = elem['baseID'].to_i
        @base            = elem['base']
        @title           = elem['title']
        @logon_time      = elem['logonDateTime'].to_time rescue nil # can be nil for non CEOs
        @logoff_time     = elem['logoffDateTime'].to_time rescue nil # Can be nil for non CEOs
        @location_id     = elem['locationID']
        @location        = elem['location']
        @ship_type_id    = elem['shipTypeID'].to_i
        @ship_type       = elem['shipType']
        @roles           = elem['roles']
        @grantable_roles = elem['grantableRoles']
      end
    end

    # Represents Reve::API#ref_types return. Used in WalletTransaction and WalletJournal, among others to qualify the "type" of the entry
    # Attributes
    # * id ( Fixnum ) - CCP's ID for the RefType
    # * name ( String ) - CCP's name for the RefType
    # See Also: Reve::API#ref_types, WalletJournal, WalletTransaction
    class RefType
      attr_reader :id, :name
      def initialize(elem) #:nodoc:
        @id   = elem['refTypeID'].to_i
        @name = elem['refTypeName']
      end
    end

    # A Skill is used in the CharacterSheet for Reve::API#character_sheet call.
    # Attributes
    # * id ( Fixnum ) - Type ID of the Skill. (Refer to CCP database dump invtypes)
    # * skillpoints ( Fixnum ) - Number of skill points invested in this skill
    # * level ( Fixnum ) - Level of the Skill
    # See Also: CharacterSheet, Reve::API#character_sheet
    class Skill
      attr_accessor :id, :unpublished, :skillpoints, :level
      def initialize(elem) #:nodoc:
        @id          = elem['typeID'].to_i
        @skillpoints = elem['skillpoints'].to_i
        @level       = elem['level'].to_i
      end
    end

    # A SkillBonus, for SkillTree and Reve::API#skill_tree.
    # Bear in mind that "SkillBonus" doesn't always mean anything useful or beneficial
    # * type ( String ) - Name of the bonus
    # * value ( String ) - Value of the bonus. This is may be Fixnum or Float or Boolean but is left as a String
    # See Also: SkillTree, Reve::API#skill_tree
    class SkillBonus
      attr_reader :type, :value
      def initialize(elem) #:nodoc:
        @type = elem['bonusType']
        @value = elem['bonusValue']
      end
    end
    
    # A SkillRequirement, for SkillTree and Reve::API#skill_tree
    # Attributes
    # * type_id ( Fixnum ) - ID of the Skill that is the SkillRequirement (Refer to CCP database dump invtypes)
    # * level ( Fixnum ) - What level of the Skill is required
    # See Also: SkillTree, Reve::API#skill_tree
    class SkillRequirement
      attr_reader :type_id, :level
      alias_method :id, :type_id
      def initialize(elem)
        @type_id = elem['typeID'].to_i
        @level = elem['skillLevel'].to_i
      end
    end

    # Holds the result of the Reve::API#skill_tree call. Currently this is not
    # nested based on group_id in each individual skill.
    # Attributes
    # * name ( String ) - Name of a Skill
    # * type_id ( Fixnum ) - ID of the Skill (Refer to CCP database dump invtypes)
    # * group_id ( Fixnum ) - Group ID of the Skill (Refer to CCP database dump invgroups)
    # * description ( Skill ) - Description of the Skill
    # * rank ( Fixnum ) - Rank of the skill
    # * attribs ( [RequiredAttribute] ) - Two-element array with the PrimaryAttribute and SecondaryAttribute for the Skill
    # * skills ( [SkillTree] ) - Nested Skills under this group. NOT USED
    # * bonuses ( [SkillBonus] ) - Bonuses given by this Skill
    # See Also: SkillBonus, RequiredAttribute, Reve::API#skill_tree
    class SkillTree
      attr_reader :name, :type_id, :group_id, :description, :rank, :attribs, :required_skills, :bonuses
      def initialize(name, typeid, groupid, desc, rank, attribs = [], skills = [], bonuses = []) #:nodoc:
        @name = name
        @type_id = typeid.to_i
        @group_id = groupid.to_i
        @rank = rank.to_i
        @attribs = attribs
        @required_skills = skills
        @bonuses = bonuses
        # turn multiline literals (embedded \n and lot of white space) into one
        # line!
        @description = desc.split(/\n/).collect { |s| s.strip }.join(' ')
      end
    end

    # Holds the result of the Reve::API#skill_in_training call.
    # Note: When a Character finishes training the API will not be updated until the Character next logs into the game.
    # Attributes
    # * tranquility_time ( Time ) - The current time on Tranquility
    # * end_time ( Time ) - When the Skill is due to end
    # * start_time ( Time ) - When the Skill training was started
    # * type_id ( Fixnum ) - ID of the Skill (Refer to CCP database dump invtypes)
    # * start_sp ( Fixnum ) - How many SP did the Character have before training was started
    # * end_sp ( Fixnum ) - How many SP will the Character have after training finishes
    # * to_level ( Fixnum ) - This is the level the Skill will be at when training is completed
    # * skill_in_training ( Boolean ) - Is there actually a skill in training? (Check this first before doing anything)
    # See Also: CharacterSheet, Reve::API#skill_in_training
    class SkillInTraining
      attr_reader :tranquility_time, :end_time, :start_time, :type_id, :start_sp, :end_sp, :to_level, :skill_in_training
      def initialize(elem) #:nodoc:
        @tranquility_time = elem['currentTQTime'].to_time
        @end_time         = elem['trainingEndTime'].to_time
        @start_time       = elem['trainingStartTime'].to_time
        @type_id          = elem['trainingTypeID'].to_i
        @start_sp         = elem['trainingStartSP'].to_i
        @end_sp           = elem['trainingDestinationSP'].to_i
        @to_level         = elem['trainingToLevel'].to_i
        @skill_in_training= elem['skillInTraining'] == '1'
      end
    end

    # Used for the Reve::API#sovereignty call.
    # Attributes
    # * system_id ( Fixnum ) - ID of the System
    # * alliance_id ( Fixnum ) - ID of the Alliance that controls the System
    # * constellation_sovereignty ( String ) - Not sure? Maybe this is if the System falls under a Constellation Sovereignty setup?
    # * level ( Fixnum ) - Not sure? Level of Constellation Sovereignty
    # * faction_id ( Fixnum ) - ID of the Faction that controls the System
    # * system_name ( String ) - Name of the System
    # See Also: Alliance, Reve::API#alliances
    # TODO: Find out what constellationSovereignty is
    class Sovereignty
      attr_reader :system_id, :alliance_id, :constellation_sovereignty, :level, :faction_id, :system_name
      def initialize(elem) #:nodoc:
        @system_id                 = elem['solarSystemID'].to_i
        @alliance_id               = elem['allianceID'] == '0' ? nil : elem['allianceID'].to_i
        @constellation_sovereignty = elem['constellationSovereignty']
        @level                     = elem['sovereigntyLevel'].to_i if elem['sovereigntyLevel']
        @faction_id                = elem['factionID'] == '0' ? nil : elem['factionID'].to_i
        @system_name               = elem['solarSystemName']
      end
    end
    
    # Used for a list of Starbases, Reve::API#starbases
    # Attributes
    # * type_id ( Fixnum ) - Type of Starbase (Refer to CCP database dump invtypes)
    # * type_name ( String ) - Name of the type of Starbase
    # * id ( Fixnum ) - ID of the Starbase
    # * system_id ( Fixnum ) - ID of the System where the Starbase is
    # * system_name ( Starbase ) - Name of the System where the Starbase is
    # See Also: StarbaseFuel, Reve::API#starbases, Reve::API#starbase_fuel
    class Starbase
      attr_reader :type_id, :type_name, :id, :system_id, :system_name
      alias_method :item_id, :id
      alias_method :location_id,:system_id
      alias_method :location_name, :system_name
      def initialize(elem) #:nodoc:
        @type_id = elem['typeID'].to_i
        @type_name = elem['typeName']
        @id = elem['itemID'].to_i
        @system_id = elem['locationID'].to_i
        @system_name = elem['locationName']
      end
    end
    
    # Used for the fuel status of a Starbase. See Reve::API#starbase_fuel
    # starbase_id is set in the Reve::API#starbase_fuel method and not here
    # Attributes
    # * type_id ( Fixnum ) - Type of fuel in the Starbase (Refer to CCP database dump invtypes)
    # * quantity ( Fixnum ) - How much of the fuel is in the Starbase
    # * starbase_id ( Fixnum ) - ID of the Starbase
    # See Also: Starbase, Reve::API#starbase_fuel, Reve::API#starbases
    class StarbaseFuel
      attr_reader :type_id, :quantity
      attr_accessor :starbase_id
      def initialize(elem) #:nodoc:
        @type_id = elem['typeID'].to_i
        @quantity = elem['quantity'].to_i
      end
    end

    # Corporation or Character WalletBalance for
    # Reve::API#personal_wallet_transactions and
    # Reve::API#corporate_wallet_balance
    # Attributes
    # * account_id ( Fixnum ) - ID of the account
    # * account_key ( String ) - Account key
    # * balance ( Float ) - Balance of the wallet
    class WalletBalance
      attr_reader :account_id, :account_key, :balance
      def initialize(elem)
        @account_id  = elem['accountID'].to_i
        @account_key = elem['accountKey']
        @balance     = elem['balance'].to_f
      end
    end
    # Corporation or Character WalletJournal for
    # Reve::API#personal_wallet_journal and 
    # Reve::API#corporate_wallet_journal
    # Attributes:
    # * date ( Time ) - Time the action occured
    # * ref_id ( Integer ) - Reference ID for this action (used with stepping through Journal Entries)
    # * reftype_id ( Integer ) - RefType id
    # * owner_name1 ( String ) - Name of the Player/Corporation/whatever that did something to owner_name2
    # * owner_name2 ( String ) - Recipient of this action (from owner_name1)
    # * owner_id1 ( Integer ) - ID of the Owner's whatever (Player/Corporation/Faction/Whatever)
    # * owner_id2 ( Integer ) - ID of the recpient (Player/Corporation/Faction/Whatever)
    # * arg_name1 ( String ) - For bounty, what caused this. (May be blank)
    # * arg_id1 ( Integer ) - ID of arg_name1
    # * amount ( Float ) - Wallet delta
    # * balance ( Float ) - New wallet balance after this action
    # * reason ( String ) - Any reason for the action. May be blank (useful in giving ISK)
    class WalletJournal
      attr_reader :date, :ref_id, :reftype_id, :owner_name1, :owner_id1, :owner_name2, :owner_id2, :arg_name1, :arg_id1, :amount, :balance, :reason
      alias_method :id, :ref_id
      def initialize(elem) #:nodoc:
        @date        = elem['date'].to_time
        @ref_id      = elem['refID'].to_i
        @reftype_id  = elem['refTypeID'].to_i
        @owner_name1 = elem['ownerName1']
        @owner_name2 = elem['ownerName2']
        @owner_id1   = elem['ownerID1'].to_i if elem['ownerID1']
        @owner_id2   = elem['ownerID2'].to_i if elem['ownerID2']
        @arg_name1   = elem['argName1']
        @arg_id1     = elem['argID1'].to_i if elem['argID1']
        @amount      = elem['amount'].to_f
        @balance     = elem['balance'].to_f
        @reason      = elem['reason']
      end
    end
    # Corporation or Character WalletTransaction for
    # Reve::API#personal_wallet_transactions and
    # Reve::API#corporate_wallet_transactions
    # Attributes
    # * created_at ( Time ) - When was the WalletTransaction created?
    # * id ( Fixnum ) - CCP's ID of the WalletTransaction. Note: This is not guaranteed to be unique. It may be best to create your own unique ID
    # * quantity ( Fixnum ) - Number of +type_id+ transacted
    # * type_name ( String ) - Name of the transacted thing
    # * price ( Float) - Price of the transacted thing
    # * client_id ( Fixnum ) - ID of the client 
    # * client_name ( String ) - Name of the client
    # * character_id ( Fixnum ) - ID of the Character
    # * station_id ( Fixnum ) - ID of the Station where the WalletTransaction took place
    # * station_name ( String ) - Name of the Station where the WalletTransaction took place
    # * type ( String ) - Not sure?
    # * transaction_for ( String ) - This is corporate or personal, mirrors the subclasses.
    class WalletTransaction
      attr_reader :created_at, :id, :quantity, :type_name, :type_id, :price, 
                  :client_id, :client_name, :character_id, :station_id, :station_name, :type,
                  :transaction_for
      def initialize(elem) #:nodoc:
        @created_at       = elem['transactionDateTime'].to_time
        @id               = elem['transactionID'].to_i
        @quantity         = elem['quantity'].to_i
        @type_name        = elem['typeName']
        @type_id          = elem['typeID'].to_i
        @price            = elem['price'].to_f
        @client_id        = elem['clientID'].to_i if elem['clientID']
        @client_name      = elem['clientName']
        @station_id       = elem['stationID'].to_i
        @station_name     = elem['stationName']
        @character_id     = elem['characterID'].to_i if elem['characterID'] && elem['characterID'] != '0'
        @type             = elem['transactionType']
        @transaction_for  = elem['transactionFor'] # This is corporate or personal, mirrors the subclasses.
      end
    end
    # For Corporate WalletTransaction (WalletTransaction#transaction_for == 'corporation')
    # See WalletTransaction
    class CorporateWalletTransaction < WalletTransaction
    end
    # For Personal WalletTransaction (WalletTransaction#transaction_for == 'personal')
    # See WalletTransaction
    class PersonalWalletTransaction < WalletTransaction
    end
  end
end
