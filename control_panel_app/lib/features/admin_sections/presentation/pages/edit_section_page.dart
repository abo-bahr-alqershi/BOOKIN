import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/section_form/section_form_bloc.dart';
import '../bloc/section_form/section_form_event.dart';
import '../bloc/section_form/section_form_state.dart';
import '../widgets/section_form_widget.dart';
import '../widgets/section_image_gallery.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookn_cp_app/injection_container.dart' as di;

class EditSectionPage extends StatefulWidget {
  final String sectionId;

  const EditSectionPage({
    super.key,
    required this.sectionId,
  });

  @override
  State<EditSectionPage> createState() => _EditSectionPageState();
}

class _EditSectionPageState extends State<EditSectionPage> {
  final GlobalKey<SectionImageGalleryState> _galleryKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    context.read<SectionFormBloc>().add(
          InitializeSectionFormEvent(sectionId: widget.sectionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SectionFormBloc, SectionFormState>(
      listener: (context, state) {
        if (state is SectionFormSubmitted) {
          _showSuccessMessage('تم تحديث القسم بنجاح');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.pop();
            }
          });
        } else if (state is SectionFormError) {
          _showErrorMessage(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SectionFormWidget(
                  isEditing: true,
                  sectionId: widget.sectionId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkSurface.withValues(alpha: 0.5),
                    AppTheme.darkSurface.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textWhite,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'تعديل القسم',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بتحديث البيانات المطلوبة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openSectionMediaDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.3),
                    AppTheme.primaryViolet.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.collections,
                    size: 18,
                    color: AppTheme.primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'وسائط القسم',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  void _openSectionMediaDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: BlocProvider(
                create: (_) => di.sl<SectionImagesBloc>(),
                child: SectionImageGallery(
                  key: _galleryKey,
                  sectionId: widget.sectionId,
                  tempKey: null,
                  isReadOnly: false,
                  maxImages: 20,
                  maxVideos: 5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
