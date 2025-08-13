document.addEventListener("DOMContentLoaded", function() {
  const selectAllCheckbox = document.getElementById("select_all");
  const userCourseCheckboxes = document.querySelectorAll(".user-course-checkbox");

  // Early return if elements don't exist
  if (!selectAllCheckbox || !userCourseCheckboxes.length) return;

  // Select all functionality
  selectAllCheckbox.addEventListener("change", function() {
    userCourseCheckboxes.forEach(checkbox => {
      checkbox.checked = this.checked;
    });
  });

  userCourseCheckboxes.forEach(checkbox => {
    checkbox.addEventListener("change", function() {
      const allChecked = Array.from(userCourseCheckboxes).every(cb => cb.checked);
      const someChecked = Array.from(userCourseCheckboxes).some(cb => cb.checked);

      selectAllCheckbox.checked = allChecked;
      selectAllCheckbox.indeterminate = someChecked && !allChecked;
    });
  });
});
