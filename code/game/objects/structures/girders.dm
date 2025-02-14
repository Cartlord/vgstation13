/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	var/state = 0
	var/material = /obj/item/stack/sheet/metal
	var/construction_length = 40
	pass_flags_self = PASSGIRDER

/obj/structure/girder/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash_flags & SMASH_WALLS)
		if(prob(25)) // Not the best solution, but this should allow for better feedback so the player realizes the mob is trying to break through and has time to retreat
			playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
			M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
			"<span class='attack'>You smash through \the [src].</span>")
			drop_stack(material, get_turf(src), 2)
			qdel(src)
		else
			M.visible_message("<span class='danger'>[M] smashes against \the [src].</span>", \
			"<span class='attack'>You smash against \the [src].</span>")

/obj/structure/girder/wood
	icon_state = "girder_wood"
	name = "wooden girder"
	material = /obj/item/stack/sheet/wood
	construction_length = 20

/obj/structure/girder/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return 1
	return ..()

/obj/structure/girder/wood/attackby(var/obj/item/W, var/mob/user)
	if(W.sharpness_flags & CHOPWOOD)
		playsound(src, 'sound/effects/woodcuttingshort.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] smashes through \the [src] with \the [W].</span>", \
							"<span class='notice'>You smash through \the [src].</span>",\
							"<span class='warning'>You hear the sound of wood being cut</span>"
							)
		qdel(src)
		new material(get_turf(src), 2)
	else
		..()

/obj/structure/girder/wood/update_icon()
	if(anchored)
		name = "wooden girder"
		icon_state = "girder_wood"
	else
		name = "displaced wooden girder"
		icon_state = "displaced_wood"

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(W.is_wrench(user))
		if(state == 0) //Normal girder or wooden girder
			if(anchored && !istype(src, /obj/structure/girder/displaced)) //Anchored, destroy it
				W.playtoolsound(src, 100)
				user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
				"<span class='notice'>You start disassembling \the [src].</span>")
				if(do_after(user, src, construction_length))
					user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", \
					"<span class='notice'>You dissasemble \the [src].</span>")
					new material(get_turf(src), 2)
					qdel(src)
			else if(!anchored) //Unanchored, anchor it
				if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring shit to shuttles / space
					to_chat(user, "<span class='notice'>You can't secure \the [src] to [istype(src.loc,/turf/space) ? "space" : "this"]!</span>")
					return

				W.playtoolsound(src, 100)
				user.visible_message("<span class='notice'>[user] starts securing \the [src].</span>", \
				"<span class='notice'>You start securing \the [src].</span>")
				if(do_after(user, src, construction_length))
					user.visible_message("<span class='notice'>[user] secures \the [src].</span>", \
					"<span class='notice'>You secure \the [src].</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					anchored = 1
					update_icon()
		else if(state == 1 || state == 2) //Clearly a reinforced girder
			W.playtoolsound(src, 100)
			user.visible_message("<span class='notice'>[user] starts [anchored ? "un" : ""]securing \the [src].</span>", \
			"<span class='notice'>You start [anchored ? "un" : ""]securing \the [src].</span>")
			if(do_after(user, src, construction_length))
				anchored = !anchored //Unachor it if anchored, or opposite
				user.visible_message("<span class='notice'>[user] [anchored ? "" : "un"]secures \the [src].</span>", \
				"<span class='notice'>You [anchored ? "" : "un"]secure \the [src].</span>")
				add_hiddenprint(user)
				add_fingerprint(user)
				update_icon()

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS)) //If we can't dig a wall, we can't dig a girder
			return

		user.visible_message("<span class='warning'>[user] starts [PK.drill_verb] \the [src] with \the [PK]</span>", \
		"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK]</span>")
		if(do_after(user, src, 30))
			user.visible_message("<span class='warning'>[user] destroys \the [src]!</span>", \
			"<span class='notice'>Your [PK] tears through the last of \the [src]!</span>")
			new material(get_turf(src))
			qdel(src)

	else if(W.is_screwdriver(user) && state == 2) //Unsecuring support struts, stage 2 to 1
		W.playtoolsound(src, 100)
		user.visible_message("<span class='warning'>[user] starts unsecuring \the [src]'s internal support struts.</span>", \
		"<span class='notice'>You start unsecuring \the [src]'s internal support struts.</span>")
		if(do_after(user, src, construction_length))
			user.visible_message("<span class='warning'>[user] unsecures \the [src]'s internal support struts.</span>", \
			"<span class='notice'>You unsecure \the [src]'s internal support struts.</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			state = 1
			update_icon()

	else if(W.is_screwdriver(user) && state == 1) //Securing support struts, stage 1 to 2
		W.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] starts securing \the [src]'s internal support struts.</span>", \
		"<span class='notice'>You start securing \the [src]'s internal support struts.</span>")
		if(do_after(user, src, construction_length))
			user.visible_message("<span class='notice'>[user] secures \the [src]'s internal support struts.</span>", \
			"<span class='notice'>You secure \the [src]'s internal support struts.</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			state = 2
			update_icon()

	else if(W.is_wirecutter(user) && state == 1) //Removing support struts, stage 1 to 0 (normal girder)
		W.playtoolsound(src, 100)
		user.visible_message("<span class='warning'>[user] starts removing \the [src]'s internal support struts.</span>", \
		"<span class='notice'>You start removing \the [src]'s internal support struts.</span>")
		if(do_after(user, src, construction_length))
			user.visible_message("<span class='warning'>[user] removes \the [src]'s internal support struts.</span>", \
			"<span class='notice'>You remove \the [src]'s internal support struts.</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			new /obj/item/stack/rods(get_turf(src), 2)
			state = 0
			update_icon()

	else if(istype(W, /obj/item/stack/rods) && state == 0 && material == /obj/item/stack/sheet/metal) //Inserting support struts, stage 0 to 1 (reinforced girder, replaces plasteel step)
		var/obj/item/stack/rods/R = W
		if(R.amount < 2) //Do a first check BEFORE the user begins, in case he's using a single rod
			to_chat(user, "<span class='warning'>You need more rods to finish the support struts.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts inserting internal support struts into \the [src].</span>", \
		"<span class='notice'>You start inserting internal support struts into \the [src].</span>")
		if(do_after(user, src,construction_length))
			var/obj/item/stack/rods/O = W
			if(O.amount < 2) //In case our user is trying to be tricky
				to_chat(user, "<span class='warning'>You need more rods to finish the support struts.</span>")
				return
			O.use(2)
			user.visible_message("<span class='notice'>[user] inserts internal support struts into \the [src].</span>", \
			"<span class='notice'>You insert internal support struts into \the [src].</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			state = 1
			update_icon()

	else if(iscrowbar(W) && state == 0 && anchored) //Turning normal girder into disloged girder
		W.playtoolsound(src, 100)
		user.visible_message("<span class='warning'>[user] starts dislodging \the [src].</span>", \
		"<span class='notice'>You start dislodging \the [src].</span>")
		if(do_after(user, src, construction_length))
			user.visible_message("<span class='warning'>[user] dislodges \the [src].</span>", \
			"<span class='notice'>You dislodge \the [src].</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			anchored = 0
			update_icon()

	else if(istype(W, /obj/item/stack))//this could be either material stacks or tile stacks
		var/use_amount = 2
		var/obj/item/stack/S = W
		if(istype(W,/obj/item/stack/sheet))//if sheet stack
			use_amount = 2
		else if(istype(W,/obj/item/stack/tile))//if tile stack
			if(!S.sheettype) //only certain tiles have walltypes
				return
			use_amount = 8	//4 tiles per sheet, this is the equivalent of 2 sheets
		switch(S.type)
			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(state) //We are trying to finish a reinforced girder with regular metal
					return
				if(!anchored)
					if(S.amount < use_amount)
						return
					var/pdiff = performWallPressureCheck(src.loc)
					if(!pdiff) //Should really not be that precise, 10 kPa is the usual breaking point
						S.use(use_amount)
						user.visible_message("<span class='warning'>[user] creates a false wall!</span>", \
						"<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
						var/obj/structure/falsewall/FW = new /obj/structure/falsewall (src.loc)
						FW.add_hiddenprint(user)
						FW.add_fingerprint(user)
						qdel(src)
					else
						to_chat(user, "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>")
						message_admins("Attempted false wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false wall made by [user.real_name] (user.ckey) at [loc] had a pressure difference of [pdiff]!")
						return
				else
					if(S.amount < use_amount)
						return ..() // ?
					user.visible_message("<span class='notice'>[user] starts installing plating to \the [src].</span>", \
					"<span class='notice'>You start installing plating to \the [src].</span>")
					if(do_after(user, src, construction_length))
						if(S.amount < use_amount) //User being tricky
							return
						S.use(use_amount)
						user.visible_message("<span class='notice'>[user] finishes installing plating to \the [src].</span>", \
						"<span class='notice'>You finish installing plating to \the [src].</span>")
						var/turf/Tsrc = get_turf(src)
						if(!istype(Tsrc))
							return 0
						for (var/obj/effect/decal/cleanable/blood/tracks/footprints in Tsrc)
							qdel(footprints)//so footprints don't suddenly move on top of the new wall
						var/turf/simulated/wall/X = Tsrc.ChangeTurf(/turf/simulated/wall)
						if(X)
							X.add_hiddenprint(user)
							X.add_fingerprint(user)
						qdel(src)
					return

			if(/obj/item/stack/sheet/plasteel)

				//Due to the way wall construction works, this uses both plasteel sheets immediately
				if(!anchored)
					if(S.amount < use_amount)
						return
					var/pdiff = performWallPressureCheck(src.loc)
					if(!pdiff)
						S.use(use_amount)
						user.visible_message("<span class='warning'>[user] creates a false reinforced wall!</span>", \
						"<span class='notice'>You create a false reinforced wall. Push on it to open or close the passage.</span>")
						var/obj/structure/falsewall/rwall/FW = new /obj/structure/falsewall/rwall(src.loc)
						FW.add_hiddenprint(user)
						FW.add_fingerprint(user)
						qdel(src)
					else
						to_chat(user, "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>")
						message_admins("Attempted false rwall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false rwall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
						return

				//We are ready to turn this reinforced girder into a beautiful reinforced wall
				//The other plasteel sheet is used in the rest of the construction steps, see walls_reinforced.dm

				if(state != 2)
					return //Coders against indents
				user.visible_message("<span class='warning'>[user] starts installing reinforced plating to \the [src].</span>", \
				"<span class='notice'>You start installing reinforced plating to \the [src].</span>")
				if(do_after(user, src, 50))
					S.use(1)
					user.visible_message("<span class='warning'>[user] finishes installing reinforced plating to \the [src].</span>", \
					"<span class='notice'>You finish installing reinforced plating to \the [src].</span>")
					var/turf/Tsrc = get_turf(src)
					for (var/obj/effect/decal/cleanable/blood/tracks/footprints in Tsrc)
						qdel(footprints)//so footprints don't suddenly move on top of the new wall
					var/turf/simulated/wall/r_wall/X = Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
					if(X)
						X.add_hiddenprint(user)
						X.add_fingerprint(user)
						X.d_state = 4 //Reinforced wall not finished yet, but since we're changing to a turf, need to transfer desired variables
						X.update_icon() //Tell our reinforced wall to update its icon
					qdel(src)
				return

		if(S.sheettype)
			var/M = S.sheettype
			var/isLegacy = FALSE
			if(istype(W,/obj/item/stack/tile)) // if using tiles, use the path for the legacy instance
				isLegacy = TRUE
			if(!anchored)
				if(S.amount < use_amount)
					to_chat(user, "<span class='warning'>Not enough material to construct. A total of [use_amount] required.</span>")
					return
				var/F
				if(!isLegacy)
					F = text2path("/obj/structure/falsewall/[M]")
				else
					F = text2path("/obj/structure/falsewall/[M]/[M]_old")
				if(!ispath(F))
					return
				var/pdiff = performWallPressureCheck(src.loc)
				if(!pdiff)
					S.use(use_amount)
					user.visible_message("<span class='warning'>[user] creates a false wall!</span>", \
					"<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/FW = new F (src.loc)
					FW.add_hiddenprint(user)
					FW.add_fingerprint(user)
					qdel(src)
				else
					to_chat(user, "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>")
					message_admins("Attempted false [M] wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
					log_admin("Attempted false [M] wall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
					return
			else
				if(S.amount < use_amount)
					to_chat(user, "<span class='warning'>Not enough material to construct. A total of [use_amount] required.</span>")
					return ..()
				var/wallpath
				if(!isLegacy)
					wallpath = text2path("/turf/simulated/wall/mineral/[M]")
				else
					wallpath = text2path("/turf/simulated/wall/mineral/[M]/[M]_old")
				if(!ispath(wallpath))
					return ..()
				if(!isLegacy)
					user.visible_message("<span class='notice'>[user] starts installing plating to \the [src].</span>", \
					"<span class='notice'>You start installing plating to \the [src].</span>")
				else
					user.visible_message("<span class='notice'>[user] starts reinforcing \the [src] with the [S.name].</span>", \
					"<span class='notice'>You start reinforcing \the [src] with the [S.name].</span>")
				if(do_after(user, src,construction_length))
					if(S.amount < use_amount) //Don't be tricky now
						return
					S.use(use_amount)
					if(!isLegacy)
						user.visible_message("<span class='notice'>[user] finishes installing plating to \the [src].</span>", \
						"<span class='notice'>You finish installing plating to \the [src].</span>")
					else
						user.visible_message("<span class='notice'>[user] finishes reinforcing \the [src] with the [S.name].</span>", \
						"<span class='notice'>You finish reinforcing \the [src] with the [S.name].</span>")
					var/turf/Tsrc = get_turf(src)
					for (var/obj/effect/decal/cleanable/blood/tracks/footprints in Tsrc)
						qdel(footprints)//so footprints don't suddenly move on top of the new wall
					var/turf/simulated/wall/mineral/X = Tsrc.ChangeTurf(wallpath)
					if(X)
						X.add_hiddenprint(user)
						X.add_fingerprint(user)
					qdel(src)
				return

		add_hiddenprint(usr)

	else if((W.sharpness_flags & (CUT_WALL)) && user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>[user] begins slicing through \the [src]!</span>", \
		"<span class='notice'>You begin slicing through \the [src].</span>", \
		"<span class='warning'>You hear slicing noises.</span>")
		playsound(src, 'sound/items/Welder2.ogg', 100, 1)

		if(do_after(user, src, 60))
			if(!istype(src))
				return
			user.visible_message("<span class='warning'>[user] slices through \the [src]!</span>", \
			"<span class='notice'>You slice through \the [src].</span>", \
			"<span class='warning'>You hear slicing noises.</span>")
			playsound(src, 'sound/items/Welder2.ogg', 100, 1)
			new material(get_turf(src), 2)
			qdel(src)

	//Wait, what, WHAT ?
	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type in list(0, 1, 5))	//Simple pipes, simple bends, and simple manifolds.
			if(user.drop_item(P, src.loc))
				user.visible_message("<span class='warning'>[user] fits \the [P] into \the [src]</span>", \
				"<span class='notice'>You fit \the [P] into \the [src]</span>")
	else
		..()

/obj/structure/girder/blob_act()
	..()
	if(prob(40))
		qdel(src)

/obj/structure/girder/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		src.ex_act(2)
	return ..()

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(25) && state == 2) //Strong enough to have a chance to stand if finished, but not in one piece
				new /obj/item/stack/rods(get_turf(src)) //Lose one ro)
				state = 0
				update_icon()
			else //Not finished or not lucky
				qdel(src) //No scraps
			return
		if(2.0)
			if(prob(50))
				if(state == 2)
					state = 1
					update_icon()
				if(state == 1)
					new /obj/item/stack/rods(get_turf(src))
					state = 0
					update_icon()
				else
					new /obj/item/stack/sheet/metal(get_turf(src))
					qdel(src)
			return
		if(3.0)
			if((state == 0) && prob(5))
				new /obj/item/stack/sheet/metal(get_turf(src))
				qdel(src)
			else if(prob(15))
				if(state == 2)
					state = 1
					update_icon()
				if(state == 1)
					new /obj/item/stack/rods(get_turf(src), 2)
					state = 0
					update_icon()
			return
	return

/obj/structure/girder/mech_drill_act(severity)
	new /obj/item/stack/sheet/metal(get_turf(src))
	qdel(src)
	return

/obj/structure/girder/update_icon()
	//Names really shouldn't be set here, but it's the only proc that checks where needed
	if(anchored)
		if(state)
			name = "reinforced girder"
			icon_state = "reinforced"
		else
			name = "girder"
			icon_state = "girder"
	else
		if(state)
			name = "displaced reinforced girder"
			icon_state = "r_displaced"
		else
			name = "displaced girder"
			icon_state = "displaced"

/obj/structure/girder/projectile_check()
	return PROJREACT_WALLS

/obj/structure/girder/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/structure/girder/clockwork, CLOCKWORK_GENERIC_GLOW)

/obj/structure/girder/displaced
	name = "displaced girder"
	icon_state = "displaced"
	anchored = 0

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
	state = 2

/obj/structure/girder/reinforced/displaced
	name = "displaced reinforced girder"
	icon_state = "r_displaced"
	anchored = 0

/obj/structure/cultgirder
	name = "cult girder"
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultgirder"
	anchored = 1
	density = 1

/obj/structure/cultgirder/clockworkify()
	return

/obj/structure/cultgirder/attackby(obj/item/W as obj, mob/user as mob)
	if(W.is_wrench(user))
		W.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		if(do_after(user, src,40))
			user.visible_message("<span class='warning'>[src] dissasembles \the [src].</span>", \
			"<span class='notice'>You dissasemble \the [src].</span>")
			//new /obj/effect/decal/remains/human(get_turf(src))	//Commented out until remains are cleanable
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS))
			return

		user.visible_message("<span class='warning'>[user] starts [PK.drill_verb] \the [src] with \the [PK].</span>",
							"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK].</span>")
		if(do_after(user, src,30))
			user.visible_message("<span class='warning'>[user] destroys \the [src]!</span>",
								"<span class='notice'>Your [PK] tears through the last of \the [src]!</span>")
			new /obj/effect/decal/remains/human(loc)
			qdel(src)

/obj/structure/cultgirder/attack_construct(mob/user as mob)
	if(istype(user, /mob/living/simple_animal/construct/builder))
		to_chat(user, "You start repairing the girder.")
		if(do_after(user,src,30))
			to_chat(user, "<span class='notice'>Girder repaired.</span>")
			var/turf/Tsrc = get_turf(src)
			if(!istype(Tsrc))
				return 0
			Tsrc.ChangeTurf(/turf/simulated/wall/cult)
			qdel(src)
		return 1
	return 0

/obj/structure/cultgirder/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash_flags & SMASH_WALLS)
		new /obj/effect/decal/remains/human(get_turf(src))
		M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
		"<span class='attack'>You smash through \the [src].</span>")
		qdel(src)

/obj/structure/cultgirder/blob_act()
	if(prob(40))
		qdel(src)

/obj/structure/cultgirder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
		if(3.0)
			if (prob(5))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
	return

/obj/structure/cultgirder/mech_drill_act(severity)
	new /obj/effect/decal/remains/human(loc)
	qdel(src)
	return

/obj/structure/girder/clockwork
	name = "clockwork girder"
	icon_state = "cog"
	material = /obj/item/stack/sheet/brass
	construction_length = 80

/obj/structure/girder/clockwork/cultify()
	return

/obj/structure/girder/clockwork/clockworkify()
	return

/obj/structure/girder/clockwork/update_icon()
	name = anchored? initial(name) : "displaced [initial(name)]"
	icon_state = anchored ? initial(icon_state) : "displaced_[initial(icon_state)]"
