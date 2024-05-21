--- STEAMODDED HEADER
--- MOD_NAME: Disenhancements
--- MOD_ID: CursedCards
--- MOD_AUTHOR: [ItsFlowwey, Victin]
--- MOD_DESCRIPTION: Adds "Disenhancements" onto cards
--- PREFIX: disenhance

----------------------------------------------
------------MOD CODE -------------------------

local mod_path = SMODS.current_mod.path
SMODS.Atlas{key = "Disenhancements", path = "Disenhancements.png", px = 71, py = 95}
SMODS.Atlas{key = "MeFirst", path = "me-first.png", px = 71, py = 126}

-- Define SMODS.Disenhancement
SMODS.Disenhancements = {}
SMODS.Disenhancement = SMODS.GameObject:extend {
	obj_table = SMODS.Disenhancements,
	obj_buffer = {},
	required_params = {
		'key',
		'name',
		'loc_txt'
	},
	set = "Disenhancement",
	config = {},
	pos = { x = 0, y = 0 },
	atlas = 'Disenhancements',
	unlocked = true,
	discovered = false,
	colour = HEX("9151b5"),
	reverse_lookup = {},
	omit_prefix = true,
	inject = function(self)
		-- Create "Disenhancement" pool if it doesn't already exist
		if not G["P_DISENHANCEMENTS"] then G["P_DISENHANCEMENTS"] = {} end
		G.P_DISENHANCEMENTS[self.key] = self
		--Create "Disenhancement" P_CENTER_POOLS if it doesn't already exist
		if not G.P_CENTER_POOLS["Disenhancement"] then G.P_CENTER_POOLS["Disenhancement"] = {} end
		SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
		self.reverse_lookup[self.key:lower()..'_disenhancement'] = self.key
		--Create "Disenhancement" sprite group if it doesn't already exist
		if not G["shared_disenhancements"] then G["shared_disenhancements"] = {} end
		G.shared_disenhancements[self.key] = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[self.atlas] or G.ASSET_ATLAS["stickers"], self.pos)
		--Creates soul_pos sprite as a separate object
		if self.soul_pos then G.shared_disenhancements[self.key.."soul_pos"] = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[self.atlas] or G.ASSET_ATLAS["stickers"], self.soul_pos) end
	end,
	process_loc_text = function(self)
		-- Create "Disenhancement" description group if it doesn't already exist
		if not G.localization.descriptions["Disenhancement"] then G.localization.descriptions["Disenhancement"] = {} end
		-- Follows the same localization that Seals do
		SMODS.process_loc_text(G.localization.descriptions.Other, self.key:lower() .. '_disenhancement', self.loc_txt, 'description')
		SMODS.process_loc_text(G.localization.misc.labels, self.key:lower() .. '_disenhancement', self.loc_txt, 'label')
	end,
	get_obj = function(self, key) return G.P_DISENHANCEMENTS[key] end,
}

function Card:set_disenhancement(_disenhancement, silent, immediate)
	self.ability.disenhancement = nil
	if _disenhancement then
		self.ability.disenhancement = _disenhancement
		if not silent then 
			G.CONTROLLER.locks.seal = true
			if immediate then 
				self:juice_up(0.3, 0.3)
				play_sound('gold_seal', 1.2, 0.4)
				G.CONTROLLER.locks.seal = false
			else
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.3,
					func = function()
						self:juice_up(0.3, 0.3)
						play_sound('gold_seal', 1.2, 0.4)
					return true
					end
				}))
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.15,
					func = function()
						G.CONTROLLER.locks.seal = false
					return true
					end
				}))
			end
		end
	end
	if self.ability.disenhancement == "me_first" then self.ability.forced_selection = true end
end

SMODS.Disenhancement{
	name = "Webbed",
	key = "webbed",
	loc_txt = {
		description = {
			name = "Webbed",
			text = {
				"This card cannot",
				"be selected",
			},
		},
		label = "Webbed",
	},
	colour = HEX('9151b5'),
	pos = { x = 0, y = 0 },
	atlas = 'Disenhancements',
}

SMODS.Disenhancement{
	name = "Clouded",
	key = "clouded",
	loc_txt = {
		description = {
			name = "Clouded",
			text = {
				"Consumable cards cannot",
				"be used whilst this card",
				"is in hand",
			},
		},
		label = "Clouded",
	},
	colour = HEX('9151b5'),
	pos = { x = 1, y = 0 },
	atlas = 'Disenhancements',
}

SMODS.Disenhancement{
	name = "Me First!",
	key = "me_first",
	loc_txt = {
		description = {
			name = "Me First!",
			text = {
				"This card is",
				"always selected",
			},
		},
		label = "Me First!",
	},
	colour = HEX('9151b5'),
	pos = { x = 1, y = 0 },
	soul_pos = {x = 0, y = 0},
	atlas = 'MeFirst',
}

SMODS.Consumable{
	set = "Spectral",
	name = "Test Disenhancement Applier",
	key = "test_disenhancement_applier",
	config = {extra = "webbed"},
	discovered = true,
	loc_txt = {
		name = "Test Disenhancement Applier",
		text = {
			"This Spectral card",
			"applies Test",
			"Disenhancement",
		},
	},
	use = function(self, area, copier)
		local conv_card = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            self:juice_up(0.3, 0.5)
            return true end }))
        
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
            conv_card:set_disenhancement(self.ability.extra, nil, true)
            return true end }))
        
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
	end,
	can_use = function(self)
		if G.hand and (#G.hand.highlighted == 1) and G.hand.highlighted[1] and (not G.hand.highlighted[1].edition) then return true end
	end,
}

local CardAreacan_highlight_ref = CardArea.can_highlight
function CardArea:can_highlight(card)
	if card.ability.disenhancement == "webbed" then return false end
	return CardAreacan_highlight_ref(self, card)
end

local Gameupdate_draw_to_hand_ref = Game.update_draw_to_hand
function Game:update_draw_to_hand(dt)
	Gameupdate_draw_to_hand_ref(self, dt)
	local cards_total = 0
	local webbed_cards = 0
	for i=1, #G.hand.cards do
		cards_total = cards_total + 1
		if G.hand.cards[i].ability.disenhancement and G.hand.cards[i].ability.disenhancement == "webbed" then webbed_cards = webbed_cards + 1 end
	end
	if #G.hand.cards == G.hand.config.card_limit and cards_total == webbed_cards then 
		print("All webbed cards")
		print("cards_total: "..tostring(cards_total)..", webbed_cards: "..tostring(webbed_cards))
		G.E_MANAGER:add_event(Event({
            trigger = 'after',
			delay = '0.3',
            func = function()
				G.STATE = G.STATES.GAME_OVER
				if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
					G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
				end
				G:save_settings()
				G.FILE_HANDLER.force = true
				G.STATE_COMPLETE = false
                return true
            end
        }))
	end
end

local Cardcan_use_consumeable_ref = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
	if not skip_check and ((G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))then  
		return false 
	end
	local clouded_card = nil
	if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT or any_state then
		if G.hand and G.hand.cards then
			for i=1, #G.hand.cards do
				if G.hand.cards[i].ability.disenhancement and G.hand.cards[i].ability.disenhancement == "clouded" then clouded_card = true end
			end
		end
	end
	if clouded_card then return false else return Cardcan_use_consumeable_ref(self, any_state, skip_check) end
end

----------------------------------------------
------------MOD CODE END----------------------
