extends TextureButton

@export var clickmaskImageSource: CompressedTexture2D;

func _ready() -> void:
	texture_click_mask = BitMap.new();
	texture_click_mask.create_from_image_alpha(clickmaskImageSource.get_image());
