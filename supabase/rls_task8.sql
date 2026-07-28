-- =============================================================================
-- TinySteps – Row Level Security Policies for Task 8 Tables
-- Tables: teacher_availability, teacher_leave, session_bookings
--
-- Run this in the Supabase SQL Editor (or via supabase db push).
-- Assumes auth.uid() maps to the id column in teachers/parents.
-- =============================================================================

-- =============================================================================
-- 1. teacher_availability
-- =============================================================================

ALTER TABLE teacher_availability ENABLE ROW LEVEL SECURITY;

-- Teachers can read their own availability
CREATE POLICY "Teachers can view own availability"
  ON teacher_availability
  FOR SELECT
  USING (auth.uid() = teacher_id);

-- Teachers can insert their own availability slots
CREATE POLICY "Teachers can insert own availability"
  ON teacher_availability
  FOR INSERT
  WITH CHECK (auth.uid() = teacher_id);

-- Teachers can update their own availability slots
CREATE POLICY "Teachers can update own availability"
  ON teacher_availability
  FOR UPDATE
  USING (auth.uid() = teacher_id)
  WITH CHECK (auth.uid() = teacher_id);

-- Teachers can delete their own availability slots
CREATE POLICY "Teachers can delete own availability"
  ON teacher_availability
  FOR DELETE
  USING (auth.uid() = teacher_id);

-- Parents (and admins) can read all availability so they can find available teachers
CREATE POLICY "Parents can view all teacher availability"
  ON teacher_availability
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM parents WHERE id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM admins WHERE id = auth.uid()
    )
  );


-- =============================================================================
-- 2. teacher_leave
-- =============================================================================

ALTER TABLE teacher_leave ENABLE ROW LEVEL SECURITY;

-- Teachers can read their own leave entries
CREATE POLICY "Teachers can view own leave"
  ON teacher_leave
  FOR SELECT
  USING (auth.uid() = teacher_id);

-- Teachers can apply for their own leave
CREATE POLICY "Teachers can insert own leave"
  ON teacher_leave
  FOR INSERT
  WITH CHECK (auth.uid() = teacher_id);

-- Teachers can delete (cancel) their own upcoming leave
CREATE POLICY "Teachers can delete own leave"
  ON teacher_leave
  FOR DELETE
  USING (auth.uid() = teacher_id);

-- Parents can read leave dates to know when a teacher is unavailable
CREATE POLICY "Parents can view teacher leave dates"
  ON teacher_leave
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM parents WHERE id = auth.uid()
    )
  );

-- Admins can read all leave
CREATE POLICY "Admins can view all leave"
  ON teacher_leave
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM admins WHERE id = auth.uid()
    )
  );


-- =============================================================================
-- 3. session_bookings
-- =============================================================================

ALTER TABLE session_bookings ENABLE ROW LEVEL SECURITY;

-- Parents can read their own bookings
CREATE POLICY "Parents can view own bookings"
  ON session_bookings
  FOR SELECT
  USING (auth.uid() = parent_id);

-- Parents can create bookings for themselves
CREATE POLICY "Parents can create own bookings"
  ON session_bookings
  FOR INSERT
  WITH CHECK (auth.uid() = parent_id);

-- Parents can cancel (update status to 'cancelled') their own pending bookings
CREATE POLICY "Parents can cancel own pending bookings"
  ON session_bookings
  FOR UPDATE
  USING (auth.uid() = parent_id AND status = 'pending')
  WITH CHECK (auth.uid() = parent_id);

-- Teachers can view bookings assigned to them
CREATE POLICY "Teachers can view own bookings"
  ON session_bookings
  FOR SELECT
  USING (auth.uid() = teacher_id);

-- Admins can read all bookings
CREATE POLICY "Admins can view all bookings"
  ON session_bookings
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM admins WHERE id = auth.uid()
    )
  );

-- Admins can confirm or reject any booking (update status)
CREATE POLICY "Admins can update booking status"
  ON session_bookings
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM admins WHERE id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins WHERE id = auth.uid()
    )
  );

-- =============================================================================
-- End of Task 8 RLS Policies
-- =============================================================================
