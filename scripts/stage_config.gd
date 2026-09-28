class_name StageConfig
extends Resource

@export_category("Stage")
@export var stage_id := "stage_01"
@export var display_name := "Stage 1 - Outer Reef"
@export var difficulty_label := "NORMAL"

@export_category("Enemy Difficulty")
@export_range(0.5, 5.0, 0.1) var enemy_health_multiplier := 1.0
@export_range(0.5, 3.0, 0.05) var enemy_speed_multiplier := 1.0
@export_range(0.25, 3.0, 0.05) var spawn_interval_multiplier := 1.0

@export_category("Boss Fight")
@export_range(100, 100000, 100) var boss_score_requirement := 2500
@export_range(1, 10000, 1) var boss_max_health := 80
@export_range(20.0, 300.0, 5.0) var boss_move_speed := 85.0
@export_range(0.1, 5.0, 0.05) var boss_fire_interval := 0.72
@export_range(0, 100000, 100) var boss_score_reward := 5000

@export_category("Rewards")
@export_range(0, 100000, 1) var clear_token_reward := 100
@export_range(1, 100000, 1) var score_per_bonus_token := 250
