import flatpickr from "flatpickr";

document.addEventListener('turbo:load', function() {
  const startInput = document.getElementById('activity_start_time');
  const endInput = document.getElementById('activity_end_time');

  if (startInput && endInput) {
    const endPicker = flatpickr(endInput, {
      enableTime: true,
      dateFormat: "Y-m-d H:i"
    });

    flatpickr(startInput, {
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      onChange: function(selectedDates) {
        if (selectedDates.length > 0) {
          const startDate = selectedDates[0];
          // Set end time to 4 hours later if not set or before start
          let endDate = endPicker.selectedDates[0];
          if (!endDate || endDate <= startDate) {
            const newEnd = new Date(startDate.getTime() + 4 * 60 * 60 * 1000);
            endPicker.setDate(newEnd, true);
          }
        }
      }
    });
  }
});