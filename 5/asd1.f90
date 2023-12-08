
program main
    use iso_fortran_env, only: int64
    implicit none

    type :: range_map
        integer(8) :: dst
        integer(8) :: src
        integer(8) :: len
    end type range_map

    integer, parameter :: MAP_SIZE = 1024

    integer(8) :: seeds(20)
    integer :: seeds_count = 20

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
    integer :: stat,io,n,read_mode,m
    character(1024) :: iomsg
    
    integer(8) :: mapped = 0
    integer(8) :: smallest_mapped = huge(0_int64)

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
            read(readin(7:),*) seeds(:)
            cycle
        end if

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
    do n = 1, size(seeds)
        print *, seeds(n)
    end do

    do n=1, seeds_count
        mapped = seeds(n)
        do m=1,7
            call map_to(mapped,mapped,maps, maps_counts(m),m)
        end do
        if (smallest_mapped > mapped) then
            smallest_mapped=mapped
        end if
    end do

    print *, "smallest seed loc: ",smallest_mapped

contains

subroutine map_to(in,out,maps,maps_count,m)
    implicit none
    integer(8),intent(in) :: in
    integer(8),intent(out):: out
    type(range_map),intent(in) :: maps(:,:)
    integer,intent(in) :: maps_count
    integer,intent(in) :: m

    integer(8) :: n,i

    integer(8) :: mapped = 0
    
    mapped = in
    
    ! a -> b
    ! a+n -> b+n
    do i = 1, maps_count
        if(mapped >= maps(m,i)%src .and. mapped <= maps(m,i)%src+maps(m,i)%len-1) then
            !map range found
            mapped = (mapped - maps(m,i)%src) + maps(m,i)%dst
            exit
        end if
    end do

    out = mapped
end subroutine map_to



end program main