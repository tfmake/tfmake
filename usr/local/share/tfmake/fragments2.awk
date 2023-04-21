BEGIN {
  FS = OFS = "\t"

  if (ARGC < 3) exit 1
  max = ARGV[2]
  ARGV[2] = ""

  b_start = skip = 0
}

# each line is made by two fields: "section" and "bytes"
{
  b_end = $2

  diff = b_end - b_start

  # number of bytes is lower than or equal to max
  if (diff <= max) {
    if (count + diff > max) {
      # including the current bytes exceeds max, fragment it!
      fragment(skip, count, "false", "false")

      # set the accumulator to the current bytes
      count = diff

      # set skip to the current section start
      skip = b_start
    } else {
      count += diff
    }
  }

  # number of bytes is greater than max
  if (diff > max) {
    if (count > 0) {
      # there is some accumulated value, fragment it!
      fragment(skip, count, "false", "false")

      # reset the accumulator
      count = 0
    }

    # fragment the section itself; a = b * q + r
    b = diff % max > 0 ? int(diff / max) + 1 : diff/max
    q = int(diff / b)
    r = diff % b

    for (i = 1; i <= b; i++) {
      fragment(b_start + q * (i - 1), i == b ? q + r : q, i == 1 ? "false" : "true", i == b ? "false" : "true")
    }

    # move the skip forward
    skip = b_end
  }

  # move forward
  b_start = b_end
}

END {
  # if some value remains, fragment it!!!
  if (count > 0) {
    fragment(skip, count, "false", "false")
  }
}

# fragment prints four values using OFS ("\t") as output separator;
# "skip" and "count", to be use by `dd bs=1 skip="${skip}" count="${count}"`;
# "header" and "footer", to indicate if the fragment should be
# augmented at the beginning or end, or both.
function fragment(skip, count, header, footer) {
  print skip, count, header, footer
}
