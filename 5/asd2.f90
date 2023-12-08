
program main
    use iso_fortran_env, only: int64
    implicit none

    type :: range_map
        integer(8) :: dst
        integer(8) :: src
        integer(8) :: len
    end type range_map

    integer, parameter :: MAP_SIZE = 1024

    integer(8) :: seeds_read(20)
    integer(8) :: seeds(MAP_SIZE)
    integer :: seeds_count = 20

    integer(8) :: new_seeds(MAP_SIZE)
    integer :: new_seeds_count = 1
    integer(8) :: seed_l,seed_h

    integer, parameter :: seed_to_soil_map            = 1
    integer, parameter :: soil_to_fertilizer_map      = 2
    integer, parameter :: fertilizer_to_water_map     = 3
    integer, parameter :: water_to_light_map          = 4
    integer, parameter :: light_to_temperature_map    = 5
    integer, parameter :: temperature_to_humidity_map = 6
    integer, parameter :: humidity_to_location_map    = 7


    type(range_map) :: maps(7,MAP_SIZE)
    integer :: maps_counts(7)

    character(1024) :: readin
    character(*),parameter :: fname = "input"
    integer :: stat,io,read_mode,m,n,i
    character(1024) :: iomsg
    
    integer(8) :: mapped = 0
    integer(8) :: smallest_mapped = huge(0_int64)

    integer(8) :: beg,end,del
    !---------------------------------------------------------------
    ! open file
    open(newunit=io, file=fname, iostat=stat, &
    status="old", action="read", iomsg=iomsg)
    if(stat /= 0) then
        print *, trim(iomsg)
        call exit(1)
    end if

    maps_counts=1
    ! parse the file
    do while(stat == 0)
        read(io,'(A)',iostat=stat) readin
        !print *, stat, readin
        if(readin(1:6) == "seeds:") then
            read(readin(7:),*) seeds_read(:)
            cycle
        end if
        do n=1,seeds_count
            seeds(n) = seeds_read(n)
        end do

        select case(readin)
            case("seed-to-soil map:")
                read_mode=1
                cycle
            case("soil-to-fertilizer map:")
                read_mode=2
                cycle
            case("fertilizer-to-water map:")
                read_mode=3
                cycle
            case("water-to-light map:")
                read_mode=4
                cycle
            case("light-to-temperature map:")
                read_mode=5
                cycle
            case("temperature-to-humidity map:")
                read_mode=6
                cycle
            case("humidity-to-location map:")
                read_mode=7
                cycle
            case("")
                cycle
        end select

        read(readin,*) maps(read_mode,maps_counts(read_mode))%dst,&
                       maps(read_mode,maps_counts(read_mode))%src,&
                       maps(read_mode,maps_counts(read_mode))%len
        maps_counts(read_mode) = maps_counts(read_mode)+1
            
    end do

    print *, "SEEDS:"
    do n = 1, seeds_count
        print *, seeds(n)
    end do

    maps_counts(7)=maps_counts(7)-1

    do m=1,7
        call rm_sort( maps(m,:), maps_counts(m)-1 )
    end do

    do m=1,7
        print *,"-- ",m
        do i=1,maps_counts(m)-1
            print *, maps(m,i)%src, maps(m,i)%src+maps(m,i)%len, maps(m,i)%dst-maps(m,i)%src
        end do
        print *, "-------------------------------------------------------------"
    end do

    !prepare seed ranges
    n=1
    do while(n < seeds_count)
        seeds(n+1) = seeds(n)+seeds(n+1)
        n=n+2
    end do

    do m=1,7
        n=1
        new_seeds_count=1
        do while(n < seeds_count)
            !print *, n, seeds_count, new_seeds_count
            stat = 1
            seed_l = seeds(n)
            seed_h = seeds(n+1)
            n=n+2
            do i=1,maps_counts(m)-1
                beg = maps(m,i)%src
                end = maps(m,i)%src + maps(m,i)%len
                del = maps(m,i)%dst - maps(m,i)%src
                print *,beg,end,del,seed_l,seed_h

                if(seed_l < beg) then
                    if(seed_h <= beg) then
                        new_seeds(new_seeds_count)   = seed_l
                        new_seeds(new_seeds_count+1) = seed_h
                        new_seeds_count= new_seeds_count+2
                        stat = 0
                        exit
                    else 
                        new_seeds(new_seeds_count)   = seed_l
                        new_seeds(new_seeds_count+1) = beg
                        new_seeds_count= new_seeds_count+2
                        seed_l = beg
                    end if
                end if
                if (beg <= seed_l .and. seed_l < end) then
                    new_seeds(new_seeds_count)   = seed_l + del
                    if( seed_h < end ) then
                        new_seeds(new_seeds_count+1) = seed_h + del
                        print *, "lol"
                    else
                        new_seeds(new_seeds_count+1) = end + del
                        print *, "lol2"
                    end if
                    new_seeds_count= new_seeds_count+2
                    if(seed_h <= end) then
                        stat = 0
                        exit
                    else
                        seed_l = end
                    end if
                end if

            end do ! maps loop
            print *, "-------------------------------------------"
            
            if(stat/=0)then
                new_seeds(new_seeds_count)   = seed_l
                new_seeds(new_seeds_count+1) = seed_h
                new_seeds_count= new_seeds_count+2
            end if
        end do ! seeds loops

        ! put in new seeds
        print *, "########"
        do i=1,new_seeds_count-1
            seeds(i) = new_seeds(i)
            print *, seeds(i)
        end do
        seeds_count = new_seeds_count
        print *, "########"
        

    end do! map types loop

    n=1
    do while(n < new_seeds_count)
        print *, new_seeds(n),new_seeds(n+1)
        if (smallest_mapped > new_seeds(n)) then
            smallest_mapped = new_seeds(n)
        end if
        n = n + 2
    end do

    print *, "smallest seed loc: ",smallest_mapped

contains


subroutine rm_sort(a, size_a)
    implicit none
    type(range_map), dimension(:), intent(inout) :: a(:)
    
    integer :: i, j, increment, size_a
    type(range_map) :: temp
    
    increment = size_a / 2
    do while ( increment > 0 )
       do i = increment+1, size_a
          j = i
          temp = a(i)
          do while ( j >= increment+1 .and. (a(j-increment)%src > temp%src) )
             a(j) = a(j-increment)
             j = j - increment
          end do
          a(j) = temp
       end do
       if ( increment == 2 ) then
          increment = 1
       else
          increment = increment * 5 / 11
       end if
    end do
  end subroutine rm_sort

end program main


! Part 2:  69841803