extends Node

static func centroid(points:Array) -> Vector2:
  var centroid:Vector2 = Vector2.ZERO

  if points.size() == 0:
    return centroid

  for _point in points:
    centroid += _point

  centroid = centroid / float(points.size())

  return centroid

static func free_children(node):
  for n in node.get_children():
      n.free()

static func queue_free_children(node):
  for n in node.get_children():
      n.queue_free()
