# PROTOTYPE - NOT FOR PRODUCTION
# Question: Is the '布局 → 观战 → 收集奖励' core loop engaging enough?
# Date: 2026-03-24

# Run this script to test the battle prototype
# Usage: godot --headless --script res://prototypes/auto-battle/test_battle.gd

extends SceneTree

func _init() -> void:
	print("=== AUTO-BATTLE PROTOTYPE TEST ===")
	print("")

	# Create battle manager
	var battle = BattleManager.new()

	# Simulate battle
	print("Starting battle...")
	print("Player units: 3 (warrior, archer, mage)")
	print("Enemy units: 3 (warrior, archer, warrior)")
	print("")

	battle.start_battle()

	# Wait for battle to complete
	while battle.current_state == BattleManager.State.FIGHTING:
		await get_tree().create_timer(0.1).timeout

	# Get results
	var result = battle.get_result()
	print("=== BATTLE RESULT ===")
	print("State: ", "VICTORY" if result["state"] == BattleManager.State.VICTORY else "DEFEAT")
	print("Turns: ", result["turns"])
	print("Player survivors: ", result["player_survivors"])
	print("")

	# Run multiple tests for statistics
	print("=== RUNNING 10 BATTLES ===")
	var victories := 0
	var total_turns := 0

	for i in range(10):
		var test_battle = BattleManager.new()
		test_battle.start_battle()
		while test_battle.current_state == BattleManager.State.FIGHTING:
			await get_tree().create_timer(0.01).timeout

		var r = test_battle.get_result()
		if r["state"] == BattleManager.State.VICTORY:
			victories += 1
		total_turns += r["turns"]

	print("Victories: %d/10" % victories)
	print("Average turns: %.1f" % (float(total_turns) / 10.0))
	print("")

	# Assessment
	print("=== PROTOTYPE ASSESSMENT ===")
	if victories >= 5:
		print("- Balance seems reasonable (player can win)")
	else:
		print("- Balance may need adjustment (player loses too often)")

	if total_turns <= 30:
		print("- Battle length is appropriate (quick)")
	else:
		print("- Battles may be too long")

	print("")
	print("=== PROTOTYPE COMPLETE ===")
	quit()
