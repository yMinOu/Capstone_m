import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/community/data/models/post_model.dart';
import 'package:nihongo/features/community/presentation/providers/community_provider.dart';

class CommunityWriteScreen extends ConsumerStatefulWidget {
  final PostModel? post;
  const CommunityWriteScreen({super.key, this.post});

  @override
  ConsumerState<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends ConsumerState<CommunityWriteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  late String _selectedCategory;
  final List<String> _categories = ['공부 이야기', '스터디 모집', '문제 질문', '잡담'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title);
    _contentController = TextEditingController(text: widget.post?.content);
    
    // widget.post?.category가 _categories에 있는지 확인 후 설정, 없으면 기본값 사용
    if (widget.post != null && _categories.contains(widget.post!.category)) {
      _selectedCategory = widget.post!.category;
    } else {
      _selectedCategory = '공부 이야기';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          if (_selectedImages.length + images.length <= 10) {
            _selectedImages.addAll(images);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('사진은 최대 10장까지 선택 가능합니다.')),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    if (widget.post != null) {
      await ref.read(postNotifierProvider.notifier).updatePost(
            postId: widget.post!.id,
            title: title,
            content: content,
            category: _selectedCategory,
          );
    } else {
      await ref.read(postNotifierProvider.notifier).createPost(
            title: title,
            content: content,
            category: _selectedCategory,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 성공/실패 상태를 리스닝하여 처리
    ref.listen<AsyncValue<void>>(postNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (mounted) {
            Navigator.pop(context);
          }
        },
        error: (error, stack) {
          if (mounted) {
            final message = widget.post != null ? '수정' : '등록';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('게시글 $message 중 오류가 발생했습니다: $error')),
            );
          }
        },
      );
    });

    final state = ref.watch(postNotifierProvider);
    final isLoading = state.isLoading;
  // ... (the rest of the build method)

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategory,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textBlack),
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            dropdownColor: AppColors.background,
            elevation: 0,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
            items: _categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submitPost,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textBlack,
                    ),
                  )
                : Text(
                    widget.post != null ? '수정' : '등록',
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
        shape: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: TextField(
                  controller: _titleController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: '제목',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _contentController,
                    enabled: !isLoading,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: '내용을 입력해주세요.',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    style: const TextStyle(fontSize: 15, color: AppColors.textBlack),
                  ),
                ),
              ),
              // 이미지 미리보기 영역
              if (_selectedImages.isNotEmpty)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImages[index].path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: isLoading ? null : () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textBlack),
                      onPressed: isLoading ? null : _pickImages,
                    ),
                    Text(
                      '${_selectedImages.length}/10',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
