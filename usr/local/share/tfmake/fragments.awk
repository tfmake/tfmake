BEGIN {
  FS = OFS = "\t"

  if (ARGC < 3) exit 1
  max = ARGV[2]
  ARGV[2] = ""

  b_start = offset = 1
}

# each line is made by two fields: "section" and "bytes"
{
  b_end = $2

  diff = b_end - b_start + 1

  # number of bytes is equal or greater than max
  if (diff >= max) {
    if (acc > 0) {
      # there is some accumulated value, fragment it!
      fragment(offset, acc, "false", "false")

      # reset the accumulator
      acc = 0
    }

    # fragment the section itself; a = b * q + r
    b = diff % max > 0 ? int(diff / max) + 1 : diff/max
    q = int(diff / b)
    r = diff % b

    for (i = 1; i <= b; i++) {
      fragment(b_start + q * (i - 1), i == b ? q + r : q, i == 1 ? "false" : "true", i == b ? "false" : "true")
    }

    # move the offset forward
    offset = b_end + 1
  }

  # number of bytes is lower than max
  if (diff < max) {
    if (acc + diff > max) {
      # including the current bytes exceeds max, fragment it!
      fragment(offset, acc, "false", "false")

      # set the accumulator to the current bytes
      acc = diff

      # set offset to the current section start
      offset = b_start
    } else {
      acc += diff
    }
  }

  # move forward
  b_start = b_end + 1
}

END {
  # if some accumulated value remains, fragment it!!!
  if (acc > 0) {
    fragment(offset, acc, "false", "false")
  }
}

# fragment prints four values using OFS ("\t") as output separator;
# "offset" and "size", to be use by `tail -c +offset <file> | head -c size`;
# "header" and "footer", to indicate if the fragment should be
# augmented at the beginning or end, or both.
function fragment(offset, size, header, footer) {
  print offset, size, header, footer
}
