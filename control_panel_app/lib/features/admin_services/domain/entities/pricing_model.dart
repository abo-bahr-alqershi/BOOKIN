/// 📊 نماذج التسعير
enum PricingModel {
  perBooking('PerBooking', 'لكل حجز'),
  perDay('PerDay', 'لكل يوم'),
  perPerson('PerPerson', 'لكل شخص'),
  perUnit('PerUnit', 'لكل وحدة'),
  perHour('PerHour', 'لكل ساعة'),
  fixed('Fixed', 'سعر ثابت');

  final String value;
  final String label;

  const PricingModel(this.value, this.label);

  static PricingModel fromValue(String value) {
    return PricingModel.values.firstWhere(
      (model) => model.value == value,
      orElse: () => PricingModel.perBooking,
    );
  }
}