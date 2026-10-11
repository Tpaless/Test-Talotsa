extends Node2D

const DISPLAY_DURATION := 3.0
const SLIDE_DURATION := 0.25
const TITLE_FONT = preload("res://PROJECT _ DESIGN/PixeloidSans-Bold.ttf")
const DETAIL_FONT = preload("res://assets/fonts/NotoSansThai.ttf")

@export var game_path: NodePath
@onready var game: Node = get_node(game_path)

var pending: Array[Dictionary] = []
var current: Dictionary = {}
var elapsed := 0.0
var panel := StyleBoxFlat.new()


func _ready() -> void:
	panel.bg_color = Color("063d63")
	panel.border_color = Color("fff09a")
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(14)
	visible = false


func enqueue(title: String, detail: String) -> void:
	pending.append({"title": title, "detail": detail})
	if current.is_empty():
		show_next()


func show_next() -> void:
	current = pending.pop_front() if not pending.is_empty() else {}
	elapsed = 0.0
	visible = not current.is_empty()
	queue_redraw()


func clear_notifications() -> void:
	pending.clear()
	current.clear()
	elapsed = 0.0
	visible = false
	queue_redraw()


func _process(delta: float) -> void:
	if current.is_empty() or game.paused:
		return
	elapsed += delta
	if elapsed >= DISPLAY_DURATION:
		show_next()
	queue_redraw()


func _draw() -> void:
	if current.is_empty():
		return
	var entrance := clampf(elapsed / SLIDE_DURATION, 0.0, 1.0)
	var exit_progress := clampf((DISPLAY_DURATION - elapsed) / SLIDE_DURATION, 0.0, 1.0)
	var progress := minf(entrance, exit_progress)
	modulate.a = progress
	draw_set_transform(Vector2(0.0, (1.0 - progress) * -24.0))
	draw_style_box(panel, Rect2(30.0, 96.0, 480.0, 88.0))
	# Small trophy drawn in the game's gold/cyan palette.
	draw_circle(Vector2(66.0, 139.0), 25.0, Color("087b91"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(53.0, 124.0), Vector2(79.0, 124.0), Vector2(75.0, 141.0),
		Vector2(66.0, 147.0), Vector2(57.0, 141.0)
	]), Color("fff09a"))
	draw_line(Vector2(66.0, 145.0), Vector2(66.0, 153.0), Color("fff09a"), 4.0)
	draw_line(Vector2(57.0, 155.0), Vector2(75.0, 155.0), Color("fff09a"), 4.0)
	draw_string(TITLE_FONT, Vector2(104.0, 118.0), "ACHIEVEMENT", HORIZONTAL_ALIGNMENT_LEFT, 382.0, 12, Color("fff09a"))
	draw_string(TITLE_FONT, Vector2(104.0, 143.0), str(current.title), HORIZONTAL_ALIGNMENT_LEFT, 382.0, 19, Color.WHITE)
	draw_string(DETAIL_FONT, Vector2(104.0, 169.0), str(current.detail), HORIZONTAL_ALIGNMENT_LEFT, 382.0, 15, Color("b8f4ff"))
	draw_set_transform(Vector2.ZERO)
