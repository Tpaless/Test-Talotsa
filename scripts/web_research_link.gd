extends RefCounted

# Safari needs navigation inside a browser gesture, before Godot queues input.
const INSTALL_SCRIPT := """
(() => {
	const state = {data: null, touch: null};
	const canvas = document.getElementById('canvas');
	if (!canvas) return false;
	const hit = (event, point) => {
		if (!state.data || event.target !== canvas) return false;
		const bounds = canvas.getBoundingClientRect();
		if (!bounds.width || !bounds.height) return false;
		const d = state.data;
		const x = (point.clientX - bounds.left) * d.viewport[0] / bounds.width;
		const y = (point.clientY - bounds.top) * d.viewport[1] / bounds.height;
		return x >= d.rect[0] && x <= d.rect[0] + d.rect[2]
			&& y >= d.rect[1] && y <= d.rect[1] + d.rect[3];
	};
	const open = event => {
		event.preventDefault();
		event.stopImmediatePropagation();
		const link = document.createElement('a');
		link.href = state.data.url;
		link.target = '_blank';
		link.rel = 'noopener noreferrer';
		document.body.appendChild(link);
		link.click();
		link.remove();
	};
	const handlers = {
		touchstart: event => {
			state.touch = null;
			if (event.touches.length !== 1) return;
			const point = event.changedTouches[0];
			if (hit(event, point)) state.touch = {
				id: point.identifier, x: point.clientX, y: point.clientY,
				url: state.data.url
			};
		},
		touchmove: event => {
			if (!state.touch) return;
			for (const point of event.changedTouches) {
				if (point.identifier === state.touch.id
					&& Math.hypot(point.clientX - state.touch.x, point.clientY - state.touch.y) > 20)
					state.touch = null;
				if (!state.touch) break;
			}
		},
		touchcancel: () => { state.touch = null; },
		touchend: event => {
			const start = state.touch;
			state.touch = null;
			if (!start || !state.data || start.url !== state.data.url) return;
			for (const point of event.changedTouches) {
				if (point.identifier === start.id && hit(event, point)
				&& Math.hypot(point.clientX - start.x, point.clientY - start.y) <= 20) {
					open(event);
					break;
				}
			}
		},
		click: event => {
			if (event.button === 0 && hit(event, event)) open(event);
		},
		keydown: event => {
			if (state.data && !event.repeat && (event.target === canvas || event.target === document.body)
				&& ['Enter', ' '].includes(event.key)) open(event);
		}
	};
	for (const [name, handler] of Object.entries(handlers))
		document.addEventListener(name, handler, {capture: true, passive: false});
	window.__talotsaResearchLink = {
		update: data => { state.data = data; if (!data) state.touch = null; },
		dispose: () => {
			for (const [name, handler] of Object.entries(handlers))
				document.removeEventListener(name, handler, true);
			delete window.__talotsaResearchLink;
		}
	};
	return true;
})()
"""

var installed := false
var last_payload := "null"


func sync(source_url: String, button: Rect2, viewport_size: Vector2) -> void:
	if not OS.has_feature("web"):
		return
	if not installed:
		if source_url.is_empty():
			return
		installed = bool(JavaScriptBridge.eval(INSTALL_SCRIPT, true))
		if not installed:
			return
	var payload := "null"
	if not source_url.is_empty():
		payload = JSON.stringify({
			"url": source_url,
			"rect": [button.position.x, button.position.y, button.size.x, button.size.y],
			"viewport": [viewport_size.x, viewport_size.y]
		})
	if payload != last_payload:
		JavaScriptBridge.eval("window.__talotsaResearchLink.update(%s)" % payload, true)
		last_payload = payload


func dispose() -> void:
	if installed:
		JavaScriptBridge.eval("window.__talotsaResearchLink.dispose()", true)
		installed = false
		last_payload = "null"
