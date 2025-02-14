
/*

> queen bee packet
> bee net
> moveable apiary
> packet of BeezEez
> empty packet of BeezEez
> honeycomb
> The Ins and Outs of Apiculture - A Precise Art
> Deployable Hornet Hive

*/


#define MAX_BEES_PER_NET	100

////////////////////QUEEN BEE PACKET/////////////////////

////////////REGULAR BEES

/obj/item/queen_bee
	name = "queen bee packet"
	desc = "Place her into an apiary so she can get busy."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "queen_larvae"
	w_class = W_CLASS_TINY
	var/datum/bee_species/species = null

/obj/item/queen_bee/New()
	..()
	initialize()

/obj/item/queen_bee/initialize()
	species = bees_species[BEESPECIES_NORMAL]

/obj/item/queen_bee/proc/on_insertion(var/obj/machinery/apiary/A,var/mob/user)
	return

/////////////////CHILL BUG PACKET

/obj/item/queen_bee/chill
	name = "chill bug queen packet"
	desc = "Place her into an apiary so she can get busy. This species is particularly non-violent. Produces wax with calming properties."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "chill_queen_larvae"
	w_class = W_CLASS_TINY
	species = null

/obj/item/queen_bee/chill/New()
	..()
	initialize()

/obj/item/queen_bee/chill/initialize()
	species = bees_species[BEESPECIES_VOX]

/////////////////HORNET PACKET

/obj/item/queen_bee/hornet
	name = "hornet queen packet"
	desc = "Place her into an apiary so she can get busy. The queen will remember you and teach its spawn not to attack you. Don't forget to pour some beez-ez as hornets do not pollinate."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "hornet_queen_larvae"
	w_class = W_CLASS_TINY
	species = null

/obj/item/queen_bee/hornet/New()
	..()
	initialize()

/obj/item/queen_bee/hornet/initialize()
	species = bees_species[BEESPECIES_HORNET]

/obj/item/queen_bee/hornet/on_insertion(var/obj/machinery/apiary/A,var/mob/user)
	if (!A||!user)
		return
	A.faction = "\ref[user]"


////////////////////BUG NET/////////////////////

/obj/item/weapon/bee_net
	name = "bug net"
	desc = "For catching insects."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_net"
	item_state = "bee_net"
	w_class = W_CLASS_MEDIUM
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/beekeeping.dmi', "right_hand" = 'icons/mob/in-hand/right/beekeeping.dmi')
	var/list/caught_bees = list()
	var/datum/bee_species/current_species = null

/obj/item/weapon/bee_net/examine(mob/user)
	..()
	if(caught_bees.len == 1)
		to_chat(user, "<span class='info'>There's only 1 caught [current_species.common_name] in it!</span>")
		return
	if(caught_bees.len > 0)
		to_chat(user, "<span class='info'>There's [caught_bees.len] caught [current_species.common_name]\s in it!</span>")
	else
		to_chat(user, "<span class='info'>It has no bugs in it.</span>")

/obj/item/weapon/bee_net/afterattack(var/atom/A, var/mob/user, var/proximity_flag, var/click_parameters)
	if(!proximity_flag)
		return
	if(istype(A,/obj/machinery/apiary))
		return
	var/turf/T = get_turf(A)
	var/caught = 0
	for(var/mob/living/simple_animal/bee/B in T)
		if (caught_bees.len >= MAX_BEES_PER_NET)
			to_chat(user, "<span class='warning'>There are too many [current_species.common_name]\s inside \the [src] already! You have to release some before you can catch more.</span>")
			return

		if (current_species)
			if (current_species != B.bee_species)
				to_chat(user, "<span class='warning'>You gotta empty \the [src] of [current_species.common_name]\s before you can catch [B.bee_species.common_name]\s with it!</span>")
				return
		else
			current_species = B.bee_species

		caught = 1
		if(B.calmed > 0 || (B.intent != BEE_OUT_FOR_ENEMIES))
			if (!B.bee_species.angery || prob(max(0,100-B.bees.len*5)))
				for (var/datum/bee/BEES in B.bees)
					caught_bees.Add(BEES)
					B.bees.Remove(BEES)
					BEES.home = null
					if (B.home)
						B.home.bees_outside_hive.Remove(BEES)
				qdel(B)
				user.visible_message("<span class='notice'>[user] nets some [B.bee_species.common_name]\s.</span>","<span class='notice'>You net up some of the [B.bee_species.common_name]\s.</span>")
				B = null
			else
				user.visible_message("<span class='warning'>[user] swings at some [B.bee_species.common_name]\s, they don't seem to like it.</span>","<span class='warning'>You swing at some [B.bee_species.common_name]\s, they don't seem to like it.</span>")
				B.intent = BEE_OUT_FOR_ENEMIES
				B.target = user
		else
			user.visible_message("<span class='warning'>[user] swings at some [B.bee_species.common_name]\s, they don't seem to like it.</span>","<span class='warning'>The [B.bee_species.common_name]\s are too angry to let themselves get caught.</span>")
			B.intent = BEE_OUT_FOR_ENEMIES
			B.target = user
	if(!caught)
		to_chat(user, "<span class='warning'>There are no bugs in front of you!</span>")

	if (!caught_bees.len)
		current_species = null

/obj/item/weapon/bee_net/attack_self(mob/user as mob)
	empty_bees()

/obj/item/weapon/bee_net/verb/empty_bees()
	set src in usr
	set name = "Empty bee net"
	set category = "Object"
	var/mob/living/carbon/M
	if(isliving(usr))
		M = usr

	if (caught_bees.len > 0)
		if (current_species.angery)
			to_chat(M, "<span class='warning'>You empty \the [src]. The [current_species.common_name]\s are furious!</span>")
		else
			to_chat(M, "<span class='notice'>You empty \the [src].</span>")
		//release a few swarms
		while(caught_bees.len > 20)
			var/mob/living/simple_animal/bee/B = new(get_turf(src))
			for (var/i = 1 to 20)
				var/datum/bee/BEE = pick(caught_bees)
				caught_bees.Remove(BEE)
				if (current_species.angery)
					BEE.intent = BEE_OUT_FOR_ENEMIES
				B.addBee(BEE)
			if (current_species.angery)
				B.intent = BEE_OUT_FOR_ENEMIES
				B.target = M


		//what's left over
		var/mob/living/simple_animal/bee/B = new(get_turf(src))
		while(caught_bees.len > 0)
			var/datum/bee/BEE = pick(caught_bees)
			caught_bees.Remove(BEE)
			if (current_species.angery)
				BEE.intent = BEE_OUT_FOR_ENEMIES
			B.addBee(BEE)
		if (current_species.angery)
			B.intent = BEE_OUT_FOR_ENEMIES
			B.target = M
		current_species = null
	else
		to_chat(M, "<span class='warning'>There are no bees inside the net!</span>")


/obj/item/apiary
	name = "moveable apiary"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary_item"
	item_state = "giftbag"
	w_class = W_CLASS_HUGE
	var/buildtype = /obj/machinery/apiary


/obj/item/weapon/reagent_containers/food/snacks/beezeez
	name = "packet of BeezEez"
	desc = "Delicious nutrients for domesticated bees. Helps jumpstarting a new colony, and purging an existing one from toxins."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "beezeez"
	trash = /obj/item/trash/beezeez
	volume = 3

/obj/item/weapon/reagent_containers/food/snacks/beezeez/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 1


/obj/item/trash/beezeez
	name = "empty packet of BeezEez"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "beezeez-empty"


/obj/item/weapon/reagent_containers/food/snacks/honeycomb
	name = "honeycomb"
	icon_state = "honeycomb"
	desc = "Dripping with sugary sweetness. Grind it to separate the honey."
	starting_materials = list(MAT_WAX = 4*CC_PER_SHEET_WAX)
	var/list/authentic = list()

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/New()
	. = ..()
	reagents.add_reagent(HONEY,10)
	reagents.add_reagent(NUTRIMENT, 0.5)
	reagents.add_reagent(SUGAR, 2)
	bitesize = 2

	var/image/I = image('icons/obj/food.dmi', icon_state="honeycomb-color")
	I.color = mix_color_from_reagents(reagents.reagent_list)
	icon_state = "honeycomb-base"
	extra_food_overlay.overlays += I
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/chill
	name = "honeycomb"
	icon_state = "honeycomb"

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/chill/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent(CHILLWAX,10)
	reagents.add_reagent(NUTRIMENT, 0.5)
	reagents.add_reagent(SUGAR, 2)
	bitesize = 2

	var/image/I = image('icons/obj/food.dmi', icon_state="honeycomb-color")
	I.color = mix_color_from_reagents(reagents.reagent_list)
	icon_state = "chill_honeycomb-base"
	extra_food_overlay.overlays.len = 0
	extra_food_overlay.overlays += I
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/proc/authentify()
	authentic = list()
	for (var/datum/reagent/R in reagents.reagent_list)
		authentic[R.id] = R.volume

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/proc/verify()
	for (var/datum/reagent/R in reagents.reagent_list)
		if (!(R.id in authentic) || (authentic[R.id] != R.volume))//making sure that no reagent has been added or changed
			return FALSE
		else
			authentic -= R.id

	if (authentic.len <= 0)//are we sure no reagent has been removed shomehow
		return TRUE
	return FALSE

/obj/item/weapon/book/manual/hydroponics_beekeeping
	name = "The Ins and Outs of Apiculture - A Precise Art"
	icon_state ="bookHydroponicsBees"
	item_state ="bookHydroponicsBees"
	author = "Beekeeper Dave"
	title = "The Ins and Outs of Apiculture - A Precise Art"
	id = 33
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Raising Bees</h3>

				Bees are loving but fickle creatures. Don't mess with their hive or annoy them, and you'll avoid their ire.
				If you must get on their bad side, make sure to equip proper protection gear, or sufficiently impermeable clothing to reduce the chances of getting stung.
				Bee nets allow you to pick up bees, but if there's a lot of them they might get mad at you, at which point you'll have to calm them first
				by spraying water over them. For that reason, make sure to carry an extinguisher or water sprayer at all times.
				Beezeez is a mixture of pollen pellets fit for the nutrition of domesticated bees. Excellent to kickstart a colony, or reduce one's toxicity.
				Other than that, bees are excellent pets for all the family and are excellent caretakers of one's garden:
				having a hive or two around will aid in the longevity and growth rate of plants, but be careful, toxic plants will eventually harm your colony.

				<h3>Dealing with Feral Bees</h3>

				If someone attacks the hive or some of the bees, you can bet that they won't like it and retaliate with murderous intent.
				To fix such a situation, you will have to capture the bees and place them back into their apiary. Doing so is a two step process.
				But before that, you'll want to acquire yourself a Bio suit to protect yourself from stings.
				First you need to spray the bees with water. Chemistry sprays, fire extinguishers, smoke grenades, anything works as long as it has some water in it.
				Once the bees are calmed, swing your bee net at them. If the bees aren't calmed first, you will only angry them further!
				It is strongly disadvised to empty your bee net anywhere beside in the apiary, you might have to deal with an even more ferocious outbreak if you empty your net
				outside after having caught them all.

				<h3>Collecting Honeycombs</h3>

				Collecting honeycombs is a relatively simple process, but you'll need to make some preparations, such as getting a Bio suit or prepairing another apiary where to move the bees.
				First you start by deconstructing the apiary with a hatchet. The bees will become aggressive as soon as you begin. Once the apiary is deconstructed, follow the steps in the above
				section to capture the homeless feral bees and move them to another apiary. Or simply rebuild the apiary that you just deconstructed. The honeycombs harvested this way
				are full of honey, you can grind them to process the liquid, then place it in a Condimaster to conserve it in a honey pot. Or you can just eat the honeycombs if you feel like it,
				they are delicious. You can produce a high variety of flavoured honey by having your bees harvest various plants.


				</body>
				</html>
				"}

/obj/item/deployable_wild_hornet_hive
	name = "deployable wild hornet hive"
	desc = "Cannot be picked up anymore once dropped or thrown."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "hornet_apiary-wild"
	item_state = "trashbag"
	w_class = W_CLASS_SMALL

/obj/item/deployable_wild_hornet_hive/proc/spawn_hive(var/turf/T)
	if (!gcDestroyed && loc)
		if(!T)
			T = get_turf(src)
		playsound(get_turf(src), 'sound/weapons/hivehand_empty.ogg', 75, 1, -2)
		new /obj/machinery/apiary/wild/angry/hornet/deployable(T)
		qdel(src)


/obj/item/deployable_wild_hornet_hive/dropped(var/mob/user)
	..()
	spawn(1)//no way around it since throwing also drops the item
	if (isturf(loc) && !throwing)
		spawn_hive()

/obj/item/deployable_wild_hornet_hive/afterattack(var/atom/A, var/mob/living/user, var/proximity_flag, var/click_parameters)
	if(!proximity_flag)
		return
	var/turf/T = get_turf(A)
	if(!T.density && !T.has_dense_content())
		spawn_hive(T)

/obj/item/deployable_wild_hornet_hive/throw_impact(atom/hit_atom)
	spawn_hive()


#undef MAX_BEES_PER_NET
