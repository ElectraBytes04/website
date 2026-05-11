=================
Pikmin Simulation
=================
.. class:: sub

2026-03-04

------

Goal: A self-running Pikmin-like screensaver that loops indefinitely where
an AI explorer collects objectives under constraints.

Roadmap
```````
* 2-Mode Camera: 3/4 @ Normal zoom, Eagle Eye @ Far zoom.
* Pik-Boids: Boids-like system for Pikmin movement.
* Basic Enemy Movement: Enemies moving in basic patterns.
* User-made Areas: Custom-made areas as .TSCN files.
* Objectives: Things like fruit, ship parts, or treasure scattered around the
  area. New Pikmin sprouts also count as objectives.
* Pikmin Collecting Objectives: Basic pathfinding from objective to dropoff.
* Constraints: Time limits, Pikmin death limits, etc.
* Procedural Areas: Areas can be auto-generated.
* AI-Controlled Explorer Crew: Explorers will be controlled by a state
  machine/pathfinding AI. Its goal is to collect objectives while being within
  the constraints.
* Dandori / Battle Mode: Button that drops the player into the current run. The
  level resets, player competes against the AI to collect the most objectives
  before sunset. Option to not reset the level is available.

Core Game Loop
``````````````
* Create new level.
* Scatter objectives around the level.
* Select constraints for the run.
* Spawn AI explorer crew + Onion(s).
* AI plans a route for the day, executes.
* Regenerate and repeat on day end.

Pikmin
``````
Standard Boids-like movement, however cohesion is replaced with
leader-following.

* Pikmin have differing speeds from leaf to bud to flower. They will attempt to
  align as best as they can despite this.
* If the leader stops, then all Pikmin will stop with a delay that grows with
  distance.
* When dismissed, all Pikmin in the dismissed group will move away from the
  leader a fixed distance.
* Pikmin will abandon their task to attack certain enemies.
* Whistling will assign the whistler as the Pikmin's new leader (they will not
  swap teams from AI to player, however).
* Ownership may be temporarily overridden by certain enemies.

AI Explorer Crew
````````````````
* State machines and pathfinding. No machine learning.
* Plans a full route at day start. Deviates based on cost/reward checks.
* Above two are constraint-driven ("Minimise Pikmin Loss" = avoid enemy-dense
  zones unless required, "Collect Everything At All Costs" = overly aggressive
  speed optimisation)
* The player is treated as an enemy during Battle modes, using the same
  "fight this enemy?" decision logic (based on risk of losing Pikmin vs. reward
  of killing the enemies). When attacking the player, the AI will send pikmin to
  swarm it.
* May steal the player's collected objectives during Battle modes. This will use
  the same cost/reward checks that the initial planning uses.
