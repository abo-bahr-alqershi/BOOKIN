import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/section_type.dart';
import '../../../../core/enums/section_content_type.dart';
import '../../../../core/enums/section_display_style.dart';
import '../../../../core/enums/section_target.dart';
import '../bloc/section_form/section_form_bloc.dart';
import '../bloc/section_form/section_form_event.dart';
import '../bloc/section_form/section_form_state.dart';
import 'section_type_selector.dart';
import 'section_content_type_toggle.dart';
import 'section_display_style_picker.dart';

class SectionFormWidget extends StatefulWidget {
  final bool isEditing;
  final String? sectionId;

  const SectionFormWidget({
    super.key,
    required this.isEditing,
    this.sectionId,
  });

  @override
  State<SectionFormWidget> createState() => _SectionFormWidgetState();
}

class _SectionFormWidgetState extends State<SectionFormWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _displayOrderController = TextEditingController();
  final _columnsCountController = TextEditingController();
  final _itemsToShowController = TextEditingController();

  // State
  SectionTypeEnum? _selectedType;
  SectionContentType? _selectedContentType;
  SectionDisplayStyle? _selectedDisplayStyle;
  SectionTarget? _selectedTarget;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _displayOrderController.dispose();
    _columnsCountController.dispose();
    _itemsToShowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SectionFormBloc, SectionFormState>(
      listener: (context, state) {
        if (state is SectionFormReady && widget.isEditing) {
          _populateForm(state);
        }
      },
      builder: (context, state) {
        if (state is SectionFormLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(),
                    _buildConfigurationTab(),
                    _buildAppearanceTab(),
                    _buildAdvancedTab(),
                  ],
                ),
              ),
              _buildActionButtons(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorColor: AppTheme.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'معلومات أساسية'),
          Tab(text: 'الإعدادات'),
          Tab(text: 'المظهر'),
          Tab(text: 'متقدم'),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            controller: _nameController,
            label: 'اسم القسم (داخلي)',
            hint: 'أدخل اسم القسم للاستخدام الداخلي',
            icon: Icons.label_outline,
            onChanged: (value) {
              context.read<SectionFormBloc>().add(
                    UpdateSectionBasicInfoEvent(name: value),
                  );
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _titleController,
            label: 'العنوان',
            hint: 'أدخل عنوان القسم',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'العنوان مطلوب';
              }
              return null;
            },
            onChanged: (value) {
              context.read<SectionFormBloc>().add(
                    UpdateSectionBasicInfoEvent(title: value),
                  );
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _subtitleController,
            label: 'العنوان الفرعي',
            hint: 'أدخل عنوان فرعي (اختياري)',
            icon: Icons.subtitles_outlined,
            onChanged: (value) {
              context.read<SectionFormBloc>().add(
                    UpdateSectionBasicInfoEvent(subtitle: value),
                  );
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'أدخل وصف القسم',
            icon: Icons.description_outlined,
            maxLines: 3,
            onChanged: (value) {
              context.read<SectionFormBloc>().add(
                    UpdateSectionBasicInfoEvent(description: value),
                  );
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _shortDescriptionController,
            label: 'وصف مختصر',
            hint: 'أدخل وصف مختصر للعرض السريع',
            icon: Icons.short_text,
            onChanged: (value) {
              context.read<SectionFormBloc>().add(
                    UpdateSectionBasicInfoEvent(shortDescription: value),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTypeSelector(
            selectedType: _selectedType,
            onTypeSelected: (type) {
              setState(() => _selectedType = type);
              context.read<SectionFormBloc>().add(
                    UpdateSectionConfigEvent(type: type),
                  );
            },
          ),
          const SizedBox(height: 20),
          SectionContentTypeToggle(
            selectedType: _selectedContentType,
            onTypeSelected: (type) {
              setState(() => _selectedContentType = type);
              context.read<SectionFormBloc>().add(
                    UpdateSectionConfigEvent(contentType: type),
                  );
            },
          ),
          const SizedBox(height: 20),
          _buildTargetSelector(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _displayOrderController,
                  label: 'ترتيب العرض',
                  hint: '0',
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الترتيب مطلوب';
                    }
                    if (int.tryParse(value) == null) {
                      return 'أدخل رقم صحيح';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final order = int.tryParse(value);
                    if (order != null) {
                      context.read<SectionFormBloc>().add(
                            UpdateSectionConfigEvent(displayOrder: order),
                          );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _itemsToShowController,
                  label: 'عدد العناصر',
                  hint: '10',
                  icon: Icons.view_module,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'العدد مطلوب';
                    }
                    final count = int.tryParse(value);
                    if (count == null || count < 1) {
                      return 'أدخل رقم صحيح أكبر من 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final count = int.tryParse(value);
                    if (count != null) {
                      context.read<SectionFormBloc>().add(
                            UpdateSectionConfigEvent(itemsToShow: count),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActiveSwitch(),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionDisplayStylePicker(
            selectedStyle: _selectedDisplayStyle,
            onStyleSelected: (style) {
              setState(() => _selectedDisplayStyle = style);
              context.read<SectionFormBloc>().add(
                    UpdateSectionConfigEvent(displayStyle: style),
                  );
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _columnsCountController,
            label: 'عدد الأعمدة',
            hint: '2',
            icon: Icons.view_column,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'عدد الأعمدة مطلوب';
              }
              final count = int.tryParse(value);
              if (count == null || count < 1 || count > 6) {
                return 'أدخل رقم بين 1 و 6';
              }
              return null;
            },
            onChanged: (value) {
              final count = int.tryParse(value);
              if (count != null) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionConfigEvent(columnsCount: count),
                    );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات متقدمة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 20),
          // TODO: Add advanced settings like filters, sorting, visibility, etc.
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.5),
                AppTheme.darkCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
              prefixIcon: maxLines == 1
                  ? Icon(
                      icon,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الهدف',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTargetOption(
                label: 'العقارات',
                value: SectionTarget.properties,
                isSelected: _selectedTarget == SectionTarget.properties,
                onTap: () {
                  setState(() => _selectedTarget = SectionTarget.properties);
                  context.read<SectionFormBloc>().add(
                        const UpdateSectionConfigEvent(
                            target: SectionTarget.properties),
                      );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTargetOption(
                label: 'الوحدات',
                value: SectionTarget.units,
                isSelected: _selectedTarget == SectionTarget.units,
                onTap: () {
                  setState(() => _selectedTarget = SectionTarget.units);
                  context.read<SectionFormBloc>().add(
                        const UpdateSectionConfigEvent(
                            target: SectionTarget.units),
                      );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetOption({
    required String label,
    required SectionTarget value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تفعيل القسم',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          CupertinoSwitch(
            value: _isActive,
            onChanged: (value) {
              setState(() => _isActive = value);
              context.read<SectionFormBloc>().add(
                    UpdateSectionConfigEvent(isActive: value),
                  );
            },
            activeTrackColor: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SectionFormState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.5),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 48,
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
                child: Center(
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _submitForm,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: state is SectionFormLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'تحديث' : 'إضافة',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _populateForm(SectionFormReady state) {
    _nameController.text = state.name ?? '';
    _titleController.text = state.title ?? '';
    _subtitleController.text = state.subtitle ?? '';
    _descriptionController.text = state.description ?? '';
    _shortDescriptionController.text = state.shortDescription ?? '';
    _displayOrderController.text = state.displayOrder?.toString() ?? '0';
    _columnsCountController.text = state.columnsCount?.toString() ?? '2';
    _itemsToShowController.text = state.itemsToShow?.toString() ?? '10';

    setState(() {
      _selectedType = state.type;
      _selectedContentType = state.contentType;
      _selectedDisplayStyle = state.displayStyle;
      _selectedTarget = state.target;
      _isActive = state.isActive ?? true;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<SectionFormBloc>().add(SubmitSectionFormEvent());
    }
  }
}
