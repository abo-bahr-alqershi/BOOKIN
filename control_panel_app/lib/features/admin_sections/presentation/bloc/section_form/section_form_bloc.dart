import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/enums/section_content_type.dart';
import '../../../../../core/enums/section_display_style.dart';
import '../../../../../core/enums/section_target.dart';
import '../../../../../core/enums/section_type.dart';
import '../../../domain/entities/section.dart' as domain;
import '../../../domain/usecases/sections/create_section_usecase.dart';
import '../../../domain/usecases/sections/update_section_usecase.dart';
import 'section_form_event.dart';
import 'section_form_state.dart';

class SectionFormBloc extends Bloc<SectionFormEvent, SectionFormState> {
  final CreateSectionUseCase createSection;
  final UpdateSectionUseCase updateSection;

  SectionFormBloc({
    required this.createSection,
    required this.updateSection,
  }) : super(SectionFormInitial()) {
    on<InitializeSectionFormEvent>(_onInit);
    on<UpdateSectionBasicInfoEvent>(_onUpdateBasic);
    on<UpdateSectionConfigEvent>(_onUpdateConfig);
    on<UpdateSectionAppearanceEvent>(_onUpdateAppearance);
    on<UpdateSectionFiltersEvent>(_onUpdateFilters);
    on<UpdateSectionVisibilityEvent>(_onUpdateVisibility);
    on<UpdateSectionMetadataEvent>(_onUpdateMetadata);
    on<SubmitSectionFormEvent>(_onSubmit);
  }

  void _ensureReady(Emitter<SectionFormState> emit) {
    if (state is SectionFormInitial) {
      emit(const SectionFormReady());
    }
  }

  Future<void> _onInit(
    InitializeSectionFormEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    emit(SectionFormLoading());
    emit(SectionFormReady(sectionId: event.sectionId));
  }

  Future<void> _onUpdateBasic(
    UpdateSectionBasicInfoEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _ensureReady(emit);
    if (state is SectionFormReady) {
      final s = state as SectionFormReady;
      emit(s.copyWith(
        name: event.name ?? s.name,
        title: event.title ?? s.title,
        subtitle: event.subtitle ?? s.subtitle,
        description: event.description ?? s.description,
        shortDescription: event.shortDescription ?? s.shortDescription,
      ));
    }
  }

  Future<void> _onUpdateConfig(
    UpdateSectionConfigEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _ensureReady(emit);
    if (state is SectionFormReady) {
      final s = state as SectionFormReady;
      emit(s.copyWith(
        type: event.type ?? s.type,
        contentType: event.contentType ?? s.contentType,
        displayStyle: event.displayStyle ?? s.displayStyle,
        target: event.target ?? s.target,
        displayOrder: event.displayOrder ?? s.displayOrder,
        columnsCount: event.columnsCount ?? s.columnsCount,
        itemsToShow: event.itemsToShow ?? s.itemsToShow,
        isActive: event.isActive ?? s.isActive,
      ));
    }
  }

  Future<void> _onUpdateAppearance(
    UpdateSectionAppearanceEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _ensureReady(emit);
    if (state is SectionFormReady) {
      final s = state as SectionFormReady;
      emit(s.copyWith(
        icon: event.icon ?? s.icon,
        colorTheme: event.colorTheme ?? s.colorTheme,
        backgroundImage: event.backgroundImage ?? s.backgroundImage,
      ));
    }
  }

  Future<void> _onUpdateFilters(
    UpdateSectionFiltersEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _ensureReady(emit);
    if (state is SectionFormReady) {
      final s = state as SectionFormReady;
      emit(s.copyWith(
        filterCriteriaJson: event.filterCriteriaJson ?? s.filterCriteriaJson,
        sortCriteriaJson: event.sortCriteriaJson ?? s.sortCriteriaJson,
        cityName: event.cityName ?? s.cityName,
        propertyTypeId: event.propertyTypeId ?? s.propertyTypeId,
        unitTypeId: event.unitTypeId ?? s.unitTypeId,
        minPrice: event.minPrice ?? s.minPrice,
        maxPrice: event.maxPrice ?? s.maxPrice,
        minRating: event.minRating ?? s.minRating,
      ));
    }
  }

  Future<void> _onUpdateVisibility(
    UpdateSectionVisibilityEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _ensureReady(emit);
    if (state is SectionFormReady) {
      final s = state as SectionFormReady;
      emit(s.copyWith(
        isVisibleToGuests: event.isVisibleToGuests ?? s.isVisibleToGuests,
        isVisibleToRegistered:
            event.isVisibleToRegistered ?? s.isVisibleToRegistered,
        requiresPermission: event.requiresPermission ?? s.requiresPermission,
        startDate: event.startDate ?? s.startDate,
        endDate: event.endDate ?? s.endDate,
      ));
    }
  }

  Future<void> _onUpdateMetadata(
    UpdateSectionMetadataEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _ensureReady(emit);
    if (state is SectionFormReady) {
      final s = state as SectionFormReady;
      emit(s.copyWith(metadataJson: event.metadataJson ?? s.metadataJson));
    }
  }

  Future<void> _onSubmit(
    SubmitSectionFormEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    if (state is! SectionFormReady) return;
    final s = state as SectionFormReady;

    // validate required fields
    if ((s.type == null) || (s.target == null)) {
      emit(const SectionFormError(message: 'الرجاء تحديد نوع القسم والهدف'));
      return;
    }

    emit(SectionFormLoading());
    final payload = domain.Section(
      id: s.sectionId ?? '',
      type: s.type ?? SectionTypeEnum.featured,
      contentType: s.contentType ?? SectionContentType.properties,
      displayStyle: s.displayStyle ?? SectionDisplayStyle.grid,
      name: s.name,
      title: s.title,
      subtitle: s.subtitle,
      description: s.description,
      shortDescription: s.shortDescription,
      displayOrder: s.displayOrder ?? 0,
      target: s.target!,
      isActive: s.isActive ?? true,
      columnsCount: s.columnsCount ?? 2,
      itemsToShow: s.itemsToShow ?? 10,
      icon: s.icon,
      colorTheme: s.colorTheme,
      backgroundImage: s.backgroundImage,
      filterCriteria: s.filterCriteriaJson,
      sortCriteria: s.sortCriteriaJson,
      cityName: s.cityName,
      propertyTypeId: s.propertyTypeId,
      unitTypeId: s.unitTypeId,
      minPrice: s.minPrice,
      maxPrice: s.maxPrice,
      minRating: s.minRating,
      isVisibleToGuests: s.isVisibleToGuests ?? true,
      isVisibleToRegistered: s.isVisibleToRegistered ?? true,
      requiresPermission: s.requiresPermission,
      startDate: s.startDate,
      endDate: s.endDate,
      metadata: s.metadataJson,
    );

    if ((s.sectionId ?? '').isEmpty) {
      final res = await createSection(CreateSectionParams(payload));
      res.fold(
        (failure) => emit(SectionFormError(message: failure.message)),
        (created) => emit(SectionFormSubmitted(sectionId: created.id)),
      );
    } else {
      final res = await updateSection(
          UpdateSectionParams(sectionId: s.sectionId!, section: payload));
      res.fold(
        (failure) => emit(SectionFormError(message: failure.message)),
        (updated) => emit(SectionFormSubmitted(sectionId: updated.id)),
      );
    }
  }
}

