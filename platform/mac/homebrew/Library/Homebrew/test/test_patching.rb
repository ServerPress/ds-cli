require "testing_env"
require "formula"

class PatchingTests < Homebrew::TestCase
  PATCH_URL_A = "file://#{TEST_DIRECTORY}/patches/noop-a.diff"
  PATCH_URL_B = "file://#{TEST_DIRECTORY}/patches/noop-b.diff"
  PATCH_A_CONTENTS = File.read "#{TEST_DIRECTORY}/patches/noop-a.diff"
  PATCH_B_CONTENTS = File.read "#{TEST_DIRECTORY}/patches/noop-b.diff"

  def formula(*args, &block)
    super do
      url "file://#{TEST_DIRECTORY}/tarballs/testball-0.1.tbz"
      sha1 TESTBALL_SHA1
      class_eval(&block)
    end
  end

  def teardown
    @_f.clear_cache
    @_f.patchlist.each { |p| p.clear_cache if p.external? }
  end

  def assert_patched(formula)
    shutup do
      formula.brew do
        formula.patch
        s = File.read("libexec/NOOP")
        refute_includes s, "NOOP", "libexec/NOOP was not patched as expected"
        assert_includes s, "ABCD", "libexec/NOOP was not patched as expected"
      end
    end
  end

  def test_single_patch
    assert_patched formula {
      def patches
        PATCH_URL_A
      end
    }
  end

  def test_single_patch_dsl
    assert_patched formula {
      patch do
        url PATCH_URL_A
        sha1 "fa8af2e803892e523fdedc6b758117c45e5749a2"
      end
    }
  end

  def test_single_patch_dsl_with_strip
    assert_patched formula {
      patch :p1 do
        url PATCH_URL_A
        sha1 "fa8af2e803892e523fdedc6b758117c45e5749a2"
      end
    }
  end

  def test_single_patch_dsl_with_incorrect_strip
    assert_raises(ErrorDuringExecution) do
      shutup do
        formula do
          patch :p0 do
            url PATCH_URL_A
            sha1 "fa8af2e803892e523fdedc6b758117c45e5749a2"
          end
        end.brew(&:patch)
      end
    end
  end

  def test_patch_p0_dsl
    assert_patched formula {
      patch :p0 do
        url PATCH_URL_B
        sha1 "3b54bd576f998ef6d6623705ee023b55062b9504"
      end
    }
  end

  def test_patch_p0
    assert_patched formula {
      def patches
        { :p0 => PATCH_URL_B }
      end
    }
  end

  def test_patch_array
    assert_patched formula {
      def patches
        [PATCH_URL_A]
      end
    }
  end

  def test_patch_hash
    assert_patched formula {
      def patches
        { :p1 => PATCH_URL_A }
      end
    }
  end

  def test_patch_hash_array
    assert_patched formula {
      def patches
        { :p1 => [PATCH_URL_A] }
      end
    }
  end

  def test_patch_string
    assert_patched formula { patch PATCH_A_CONTENTS }
  end

  def test_patch_string_with_strip
    assert_patched formula { patch :p0, PATCH_B_CONTENTS }
  end

  def test_patch_DATA_constant
    assert_patched formula("test", Pathname.new(__FILE__).expand_path) {
      def patches
        :DATA
      end
    }
  end
end

__END__
diff --git a/libexec/NOOP b/libexec/NOOP
index bfdda4c..e08d8f4 100755
--- a/libexec/NOOP
+++ b/libexec/NOOP
@@ -1,2 +1,2 @@
 #!/bin/bash
-echo NOOP
\ No newline at end of file
+echo ABCD
\ No newline at end of file
